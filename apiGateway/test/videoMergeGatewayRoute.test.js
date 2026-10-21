"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const {registerVideoMergeGatewayRoute} = require("../routes/videoMergeGatewayRoute");
const makeRes = () => ({ statusCode:200, status(n){this.statusCode=n;return this;},json(v){this.body=v;return this;} });
function setup(axiosPost) {
  let route;const calls=[];
  registerVideoMergeGatewayRoute({post:(p,m,h)=>route={p,m,h}}, {
    checkToken:()=>{},
    axios:{post:async(...args)=>{calls.push(args);return axiosPost?.(...args)||{status:202,data:{operationId:"op1",status:"queued"}};}},
    httpsAgent:{},projectsURL:"https://projects:9001/",
    forwardAxiosError:(res,error)=>res.status(error.response?.status||500).json(error.response?.data||{error:"SERVICE_UNAVAILABLE"}),
  });
  return {route,calls};
}
test("Gateway preserva identidade, token e ordem dos vídeos",async()=>{
  const {route,calls}=setup();const res=makeRes();
  await route.h({params:{user:"u1",project:"p1"},authUserId:"u1",authUserType:"free",body:{videoIds:["b","a"]},headers:{authorization:"Bearer token"}},res);
  assert.equal(route.p,"/:user/:project/video-merge");
  assert.equal(res.statusCode,202);
  assert.equal(calls[0][0],"https://projects:9001/u1/p1/video-merge");
  assert.deepEqual(calls[0][1],{videoIds:["b","a"]});
  assert.deepEqual(calls[0][2].headers,{Authorization:"Bearer token","X-Caller-Id":"u1","X-User-Profile":"free"});
});
test("Gateway impede criar concatenação em projeto de outro dono",async()=>{
  const {route,calls}=setup();const res=makeRes();
  await route.h({params:{user:"outra",project:"p1"},authUserId:"u1",body:{videoIds:["a","b"]}},res);
  assert.equal(res.statusCode,403);assert.equal(calls.length,0);
});
test("Gateway devolve erros do Projects Service",async()=>{
  const {route}=setup(async()=>{const e=new Error("fail");e.response={status:429,data:{error:"VIDEO_MERGE_QUOTA_EXCEEDED"}};throw e;});
  const res=makeRes();await route.h({params:{user:"u1",project:"p1"},authUserId:"u1",body:{videoIds:["a","b"]},headers:{}},res);
  assert.deepEqual([res.statusCode,res.body.error],[429,"VIDEO_MERGE_QUOTA_EXCEEDED"]);
});
