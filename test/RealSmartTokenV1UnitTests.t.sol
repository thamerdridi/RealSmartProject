//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {RealSmartTokenV1} from "../src/RealSmartTokenV1.sol";


contract RealSmartTokenV1Test is Test {
    RealSmartTokenV1 internal token;
    address internal owner;
    address internal alice;
    address internal bob;

    string constant NAME   = "RealSmart";
    string constant SYMBOL = "RST";
    uint256 constant INITIAL = 1_000 ether;

    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        bob   = makeAddr("bob");

        // deploy implementation
        RealSmartTokenV1 impl = new RealSmartTokenV1();

        // proxy with initializer
        bytes memory initData = abi.encodeCall(
            RealSmartTokenV1.initialize,
            (NAME, SYMBOL, owner, INITIAL)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);

        token = RealSmartTokenV1(address(proxy));
    }

    function test_InitState() public view{
        assertEq(token.name(), NAME);
        assertEq(token.symbol(), SYMBOL);
        assertEq(token.totalSupply(), INITIAL);
        assertEq(token.balanceOf(owner), INITIAL);
        assertEq(token.owner(), owner);
        assertEq(token.decimals(), 18);
    }

    function test_ReinitializeBlocked() public {
        vm.expectRevert();
        token.initialize(NAME, SYMBOL, owner, INITIAL);
    }

    function test_Mint_OnlyOwner() public {
        vm.prank(owner);
        token.mint(alice, 100);
        assertEq(token.balanceOf(alice), 100);

        vm.prank(alice);
        vm.expectRevert();
        token.mint(alice, 1);
    }

    function test_Burn_OnlyOwner() public {
        // owner currently holds INITIAL
        vm.prank(owner);
        token.burn(owner, 200);
        assertEq(token.balanceOf(owner), INITIAL - 200);
        assertEq(token.totalSupply(), INITIAL - 200);

        vm.prank(alice);
        vm.expectRevert();
        token.burn(owner, 1);
    }

    function test_PauseBlocksTransferMintBurn_ThenUnpause() public {
        // pause
        vm.prank(owner);
        token.pause();

        // transfer blocked
        vm.prank(owner);
        vm.expectRevert();
        token.transfer(alice, 1);

        // mint blocked
        vm.prank(owner);
        vm.expectRevert();
        token.mint(alice, 1);

        // burn blocked
        vm.prank(owner);
        vm.expectRevert();
        token.burn(owner, 1);

        // unpause
        vm.prank(owner);
        token.unpause();

        // now works
        vm.prank(owner);
        token.transfer(alice, 5);
        assertEq(token.balanceOf(alice), 5);
    }

    function test_Pause_Unpause_OnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        token.pause();

        vm.prank(owner);
        token.pause();

        vm.prank(alice);
        vm.expectRevert();
        token.unpause();

        vm.prank(owner);
        token.unpause();
    }}