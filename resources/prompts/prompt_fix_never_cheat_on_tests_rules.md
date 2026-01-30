When a test fails, you MUST fix the IMPLEMENTATION, not the test.

**Forbidden "fixes" that are actually cheating:**
- Mocking a return value to make the test pass
- Weakening assertions (changing `toBe(5)` to `toBeTruthy()`)
- Removing test cases that fail
- Adding `.skip` or commenting out failing tests
- Stubbing the function being tested to return expected values

**The ONLY time you may change a test:**
- The test itself has a bug (wrong expected value, typo)
- Upstream changes made the test's assumptions invalid (API changed, schema changed)
- AND you verify the test still tests meaningful behavior after your change

If a test fails, the test is doing its job - it found a bug. Fix the bug.
A test suite that always passes because you gutted it is worthless.