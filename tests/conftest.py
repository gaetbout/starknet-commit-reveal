
import pytest
import asyncio

'''Fix asyncio crash'''
@pytest.fixture(scope="session")
def event_loop():
    return asyncio.get_event_loop()

    