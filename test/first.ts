const Token = artifacts.require("Token");

contract("Token", accounts => {
  it("first", () =>
    Token.new()
      .then(instance => instance.balanceOf(accounts[0]))
      .then(balance =>
        assert.equal(balance.valueOf() / 10 ** 18, 56000000, "balance is 10000")
      ));
});
