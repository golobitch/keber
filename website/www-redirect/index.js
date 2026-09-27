// Sends www.keber.io/anything to https://keber.io/anything, keeping the path and the query.
export default {
  fetch(request) {
    const url = new URL(request.url);
    url.protocol = "https:";
    url.hostname = "keber.io";
    url.port = "";
    return Response.redirect(url.toString(), 301);
  },
};
