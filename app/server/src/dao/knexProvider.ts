import Knex from "knex";
import * as config from "../config/knexfile";

const client = Knex(config);

export default { get: () => client }