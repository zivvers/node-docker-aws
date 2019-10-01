import Koa from 'koa';
import Router from 'koa-router';
import { deepPing } from './dao/deepPingDao';

const app = new Koa();
const router = new Router();

router.get('/ping', async (ctx) => {
  ctx.body = "Hello World";
});

router.get('/deepPing', async (ctx) => {
  ctx.body = await deepPing();
});

app.use(router.routes());
app.listen(4000);

console.log('Server running on port 4000');