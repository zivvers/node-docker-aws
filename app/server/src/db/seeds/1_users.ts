import { generateUserId } from '../../shared/uuidFactory';
import Knex from 'knex';

exports.seed = async (knex: Knex) => {
  // Deletes existing users to start from scratch
  await knex('users').del()
    .then(() => {
      return knex('users').insert({
        id: generateUserId(),
        username: 'Charlie'
      });
    });
}