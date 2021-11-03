var express = require('express');
var router = express.Router();
const axios = require('axios').default;
const dotnetAppId = process.env.DOTNET_APP_ID;
const daprPort = process.env.DAPR_HTTP_PORT || 3500;

/* GET users listing. */
router.get('/', async  function(req, res, next) {

  if(dotnetAppId)  {
    // Because we're using Dapr here, it will add mTLS, retries, and advanced telemetry
    var data = await axios.get(`http://localhost:${daprPort}/hello`, {
      headers: {'dapr-app-id': `${dotnetAppId}`} //sets app name for service discovery
    });
    res.send(`${JSON.stringify(data.data)}`);
  }
  else {
    res.send('No DOTNET_APP_ID env variable defined. Be sure to set an env variable for the DOTNET_APP_ID for Dapr')
  }

});

module.exports = router;