export default {
  async fetch(request, env) {
    return await handleRequest(request)
  }
}

async function handleRequest(request) {
var str = `[
    {
   "id": 0,
   "name": "Unite State - Free",
   "country_code": "us",
   "type": "Shadowsocks",
   "password": "mcVGzIQM34X9jRQIVRPLUC",
   "encryptmethod": "chacha20-ietf-poly1305",
   "address": "45.85.1.121",
   "port": "12334",
   "free": 1,
   "city": "New York",
   "country": "USA"
 },
 {
    "id": 1,
    "name": "Unite State - New York",
    "country_code": "us",
    "type": "Shadowsocks",
    "password": "mtu0JgUKLl38tbdwPlxDsG",
    "encryptmethod": "chacha20-ietf-poly1305",
    "address": "209.97.133.243",
    "port": "39010",
    "free": 0,
    "city": "New York",
    "country": "USA"
  },
  {
    "id": 2,
    "name": "Unite State - San Francisco",
    "country_code": "us",
    "type": "Shadowsocks",
    "password": "nJVSMPsknaPL1SgxioVt7u",
    "encryptmethod": "chacha20-ietf-poly1305",
    "address": "143.110.158.47",
    "port": "42079",
    "free": 0,
    "city": "San Francisco",
    "country": "USA"
  },
  

 {
   "id": 3,
   "name": "United Kingdom",
   "country_code": "gb",
   "type": "Shadowsocks",
   "password": "yo8NC0UZlfRkRV8maXwyjp",
   "encryptmethod": "chacha20-ietf-poly1305",
   "address": "178.62.4.186",
   "port": "14742",
   "free": 0,
   "city": "London",
   "country": "United Kingdom"
 },
 {
   "id": 4,
   "name": "Singapore",
   "country_code": "sg",
   "type": "Shadowsocks",
   "password": "TgoZngx79rgxlIIuglTcWh",
   "encryptmethod": "chacha20-ietf-poly1305",
   "address": "206.189.38.17",
   "port": "24160",
   "free": 0,
   "city": "Singapore",
   "country": "Singapore"
 },
 {
   "id": 5,
   "name": "Germany",
   "country_code": "ge",
   "type": "Shadowsocks",
   "password": "z0k8EUHoOr61X7XKweJ3Ff",
   "encryptmethod": "chacha20-ietf-poly1305",
   "address": "164.92.189.192",
   "port": "41586",
   "free": 0,
   "city": "Berlin",
   "country": "Germany"
 },
 {
   "id": 6,
   "name": "Canada",
   "country_code": "ca",
   "type": "Shadowsocks",
   "password": "mXHduear6RDwLauobc8VSq",
   "encryptmethod": "chacha20-ietf-poly1305",
   "address": "178.128.232.139",
   "port": "3116",
   "free": 0,
   "city": "Pairs",
   "country": "France"
 },
 {
   "id": 7,
   "name": "Australia",
   "country_code": "au",
   "type": "Shadowsocks",
   "password": "Zp9HVhoiX9AFaHVabVqITI",
   "encryptmethod": "chacha20-ietf-poly1305",
   "address": "170.64.173.9",
   "port": "6748",
   "free": 0,
   "city": "Toronto",
   "country": "Australia"
 },
 {
   "id": 8,
   "name": "Netherlands",
   "country_code": "nl",
   "type": "Shadowsocks",
   "password": "i6lJ4GKjlZTAo0p6ChqHQ3",
   "encryptmethod": "chacha20-ietf-poly1305",
   "address": "134.122.52.231",
   "port": "38276",
   "free": 0,
   "city": "Amsterdam",
   "country": "Netherlands"
 }
]`;

  var jsonObj = JSON.parse(str);
  //16
  var insertedCharsArr = ["wko", "ioe", "kie", "njm", "Jue", "Kds", "hMB", "Ale", "LLO", "Jdq", "QDc", "jmA", "Poi", "ddS"]; // Array of three-character strings to insert

  for (var i = 0; i < jsonObj.length; i++) {
    var password = jsonObj[i].password;
    var insertIndex = password.length - 2;
    var insertedChars = insertedCharsArr[i % insertedCharsArr.length]; // Select set of characters cyclically
    var modifiedPassword = password.substring(0, insertIndex) + insertedChars + password.substring(insertIndex);

    jsonObj[i].password = modifiedPassword;
  }

  str = JSON.stringify(jsonObj);

  return new Response(str);
}