import random
import time
import pytest


# Flaky test #1: random failure ~40% of the time
def test_random_failure():
    value = random.random()
    assert value > 0.4, f"Got {value:.3f} — unlucky roll"


# Flaky test #2: timing-sensitive (race condition simulation)
def test_timing_sensitive():
    start = time.time()
    time.sleep(random.uniform(0.01, 0.15))
    elapsed = time.time() - start
    assert elapsed < 0.1, f"Took {elapsed:.3f}s — too slow"


# Flaky test #3: order-dependent (shared mutable state)
_shared_counter = {"value": 0}

def test_increments_counter():
    _shared_counter["value"] += 1
    assert _shared_counter["value"] == 1, f"Expected 1, got {_shared_counter['value']}"


# Stable test — always passes
def test_stable():
    assert 1 + 1 == 2
