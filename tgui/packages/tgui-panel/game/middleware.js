/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { pingSoft, pingSuccess } from '../ping/actions';
import { connectionLost, connectionRestored, roundRestarted } from './actions';
import {
  CONNECTION_LOST_AFTER,
  RECONNECT_INITIAL_DELAY,
  RECONNECT_INTERVAL,
  RECONNECT_TIMEOUT,
} from './constants';
import { selectGame } from './selectors';

const withTimestamp = (action) => ({
  ...action,
  meta: {
    ...action.meta,
    now: Date.now(),
  },
});

export const gameMiddleware = (store) => {
  let lastPingedAt;
  let nextReconnectAt;

  setInterval(() => {
    const state = store.getState();
    if (!state) {
      return;
    }
    const game = selectGame(state);
    const pingsAreFailing =
      lastPingedAt && Date.now() >= lastPingedAt + CONNECTION_LOST_AFTER;
    if (!game.connectionLostAt && pingsAreFailing) {
      store.dispatch(withTimestamp(connectionLost()));
    }
    if (game.connectionLostAt && !pingsAreFailing) {
      store.dispatch(withTimestamp(connectionRestored()));
    }

    if (
      game.roundRestartedAt &&
      pingsAreFailing &&
      Date.now() >= nextReconnectAt &&
      Date.now() < game.roundRestartedAt + RECONNECT_TIMEOUT
    ) {
      nextReconnectAt = Date.now() + RECONNECT_INTERVAL;
      Byond.command('.reconnect');
    }
  }, 1000);

  return (next) => (action) => {
    const { type } = action;

    if (type === pingSuccess.type || type === pingSoft.type) {
      lastPingedAt = Date.now();
      return next(action);
    }

    if (type === roundRestarted.type) {
      // The restart notice may arrive before the panel's first ping.
      lastPingedAt = Date.now();
      nextReconnectAt = Date.now() + RECONNECT_INITIAL_DELAY;
      return next(withTimestamp(action));
    }

    return next(action);
  };
};
