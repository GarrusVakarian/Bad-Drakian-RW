import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  mock,
  spyOn,
} from 'bun:test';

import {
  applyMiddleware,
  combineReducers,
  createStore,
} from '../../common/redux';
import { pingSoft } from '../ping/actions';
import { roundRestarted } from './actions';
import {
  RECONNECT_INITIAL_DELAY,
  RECONNECT_INTERVAL,
  RECONNECT_TIMEOUT,
} from './constants';
import { gameMiddleware } from './middleware';
import { gameReducer } from './reducer';

describe('planned restart reconnects', () => {
  let now;
  let tick;
  let store;
  let command;
  let previousByond;

  beforeEach(() => {
    now = 1000000;
    spyOn(Date, 'now').mockImplementation(() => now);
    spyOn(globalThis, 'setInterval').mockImplementation((callback) => {
      tick = callback;
      return 0;
    });
    previousByond = globalThis.Byond;
    command = mock(() => {});
    globalThis.Byond = { command };
    store = createStore(
      combineReducers({ game: gameReducer }),
      applyMiddleware(gameMiddleware),
    );
    store.dispatch(pingSoft({ afk: false }));
  });

  afterEach(() => {
    mock.restore();
    globalThis.Byond = previousByond;
  });

  const advance = (milliseconds) => {
    now += milliseconds;
    tick();
  };

  it('does not reconnect ordinary connection loss or AFK disconnects', () => {
    advance(RECONNECT_INITIAL_DELAY);
    advance(RECONNECT_INTERVAL);
    expect(store.getState().game.connectionLostAt).toBeTruthy();
    expect(command).not.toHaveBeenCalled();
  });

  it('can reconnect when the restart notice arrives before the first ping', () => {
    store = createStore(
      combineReducers({ game: gameReducer }),
      applyMiddleware(gameMiddleware),
    );
    store.dispatch(roundRestarted());
    advance(RECONNECT_INITIAL_DELAY);
    expect(command).toHaveBeenCalledWith('.reconnect');
  });

  it('waits a minute, then keeps retrying during a multi-minute outage', () => {
    store.dispatch(roundRestarted());
    advance(RECONNECT_INITIAL_DELAY - 1);
    expect(command).not.toHaveBeenCalled();
    advance(1);
    expect(command).toHaveBeenCalledWith('.reconnect');
    for (let i = 0; i < 12; i++) {
      advance(RECONNECT_INTERVAL - 1);
      expect(command).toHaveBeenCalledTimes(i + 1);
      advance(1);
      expect(command).toHaveBeenCalledTimes(i + 2);
    }
  });

  it('does not interrupt a healthy connection while shutdown is pending', () => {
    store.dispatch(roundRestarted());
    for (let i = 0; i < 10; i++) {
      advance(RECONNECT_INTERVAL);
      store.dispatch(pingSoft({ afk: true }));
    }
    expect(command).not.toHaveBeenCalled();
  });

  it('stops on restored server messages and clears the restart notice', () => {
    store.dispatch(roundRestarted());
    advance(RECONNECT_INITIAL_DELAY);
    expect(command).toHaveBeenCalledTimes(1);
    store.dispatch(pingSoft({ afk: true }));
    tick();
    expect(store.getState().game.roundRestartedAt).toBeNull();
    expect(store.getState().game.connectionLostAt).toBeNull();
    advance(RECONNECT_INITIAL_DELAY);
    expect(command).toHaveBeenCalledTimes(1);
  });

  it('stops after ten minutes and can handle a later restart', () => {
    store.dispatch(roundRestarted());
    advance(RECONNECT_INITIAL_DELAY);
    expect(command).toHaveBeenCalledTimes(1);
    advance(RECONNECT_TIMEOUT - RECONNECT_INITIAL_DELAY);
    advance(RECONNECT_INTERVAL);
    expect(command).toHaveBeenCalledTimes(1);
    store.dispatch(pingSoft({ afk: false }));
    tick();
    store.dispatch(roundRestarted());
    advance(RECONNECT_INITIAL_DELAY);
    expect(command).toHaveBeenCalledTimes(2);
  });

  it('does not retry at or beyond the ten-minute deadline', () => {
    store.dispatch(roundRestarted());
    advance(RECONNECT_INITIAL_DELAY);
    for (
      let elapsed = RECONNECT_INITIAL_DELAY + RECONNECT_INTERVAL;
      elapsed < RECONNECT_TIMEOUT;
      elapsed += RECONNECT_INTERVAL
    ) {
      advance(RECONNECT_INTERVAL);
    }
    expect(command).toHaveBeenCalledTimes(36);
    advance(RECONNECT_INTERVAL);
    advance(RECONNECT_INTERVAL);
    expect(command).toHaveBeenCalledTimes(36);
  });
});
