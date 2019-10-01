import Knex from 'knex';

exports.up = async (knex: Knex) => {
  await knex.raw(`DROP EXTENSION IF EXISTS postgis;`);
  await knex.raw(`DROP EXTENSION IF EXISTS cube;`);
  await knex.raw(`CREATE EXTENSION postgis;`);
  await knex.raw(`CREATE EXTENSION cube;`);
};

exports.down = async (knex: Knex) => {
  await knex.raw(`DROP EXTENSION IF EXISTS postgis;`);
  await knex.raw(`DROP EXTENSION IF EXISTS cube;`);
};
