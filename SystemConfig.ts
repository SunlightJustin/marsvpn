export default {
  async fetch(request, env) {
    return await handleRequest(request)
  }
}

async function handleRequest(request) {
var str = `
 {
    "free_days": 1,
    "allow_vip_short_uid": [],
    "disable_cache_node": false,
    "allow_region": null
  }`;

  return new Response(str);
}
