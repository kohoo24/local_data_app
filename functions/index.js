const functions = require("firebase-functions");
const axios = require("axios");
const cors = require("cors")({ origin: true });

exports.apiProxy = functions.runWith({
  timeoutSeconds: 30,  // 타임아웃 설정
  memory: '256MB'      // 메모리 할당
}).https.onRequest((req, res) => {
  cors(req, res, async () => {
    // OPTIONS 요청 처리
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");
      res.status(200).send(); // 사전 요청 응답
      return;
    }

    const { localCode, startDate, endDate } = req.query;
    const apiKey = functions.config().api.key;

    try {
      const apiUrl = `http://www.localdata.go.kr/platform/rest/TO0/openDataApi?authKey=${apiKey}&localCode=${localCode}&bgnYmd=${startDate}&endYmd=${endDate}`;
      const response = await axios.get(apiUrl);

      res.set("Access-Control-Allow-Origin", "*");
      res.status(200).send(response.data);
    } catch (error) {
      functions.logger.error("API 호출 중 오류 발생: ", error);
      res.status(500).send("API 호출 중 오류 발생: " + error.message);
    }
  });
});
