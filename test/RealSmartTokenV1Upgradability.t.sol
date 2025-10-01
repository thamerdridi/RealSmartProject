// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {RealSmartTokenV1} from "../src/RealSmartTokenV1.sol";

contract RealSmartTokenV2 is RealSmartTokenV1 {
    /// @custom:storage-location erc7201:realsmart.storage.v2
    struct V2Storage {
        uint16 feeBps; // example new storage
    }

    uint256 private constant _V2_SLOT_NUM =
        (uint256(keccak256("realsmart.storage.v2")) - 1) & ~uint256(0xff);

    bytes32 private constant V2_STORAGE_LOCATION = bytes32(_V2_SLOT_NUM);

    // Storage accessor (ERC-7201 pattern)
    function _v2() private pure returns (V2Storage storage s) {
        bytes32 slot = V2_STORAGE_LOCATION;
        assembly {
            s.slot := slot
        }
    }

    // new initializer for V2 (runs once, after V1 initialize)
    function initializeV2(uint16 fee) public reinitializer(2) {
        _v2().feeBps = fee;
    }

    // new functions / views
    function feeBps() external view returns (uint16) { return _v2().feeBps; }
    function version() external pure returns (string memory) { return "v2"; }
}

contract RealSmartTokenV2UpgradabilityTest is Test {
    RealSmartTokenV1 internal token; // will point to V1 and then V2 impl
    address internal owner;
    address internal alice;

    string  constant NAME   = "RealSmart";
    string  constant SYMBOL = "RST";
    uint256 constant INITIAL = 1_000 ether;

    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");

        // deploy V1 impl
        RealSmartTokenV1 impl = new RealSmartTokenV1();

        // deploy proxy with V1 initializer
        bytes memory initData = abi.encodeCall(
            RealSmartTokenV1.initialize,
            (NAME, SYMBOL, owner, INITIAL)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);

        token = RealSmartTokenV1(address(proxy));
    }

    function test_UpgradeToV2_preservesState_andAddsFeatures() public {
        // pre-upgrade checks
        assertEq(token.totalSupply(), INITIAL);
        assertEq(token.owner(), owner);
        assertEq(token.name(), NAME);

        // deploy V2 impl
        RealSmartTokenV2 impl2 = new RealSmartTokenV2();

        // owner upgrades, and calls initializeV2(123) in the same tx
        vm.prank(owner);
        token.upgradeToAndCall(
            address(impl2),
            abi.encodeCall(RealSmartTokenV2.initializeV2, (uint16(123)))
        );

        // state preserved
        assertEq(token.totalSupply(), INITIAL);
        assertEq(token.owner(), owner);

        // new functions available through the same proxy address
        RealSmartTokenV2 v2 = RealSmartTokenV2(address(token));
        assertEq(v2.version(), "v2");
        assertEq(v2.feeBps(), 123);

        // old behavior still works (e.g., pausability)
        vm.prank(owner);
        v2.pause();
        vm.prank(owner);
        vm.expectRevert();
        v2.transfer(alice, 1);
        vm.prank(owner);
        v2.unpause();
    }

    function test_Upgrade_RevertsIfNotOwner() public {
        RealSmartTokenV2 impl2 = new RealSmartTokenV2();

        vm.prank(alice);
        vm.expectRevert(); // onlyOwner enforced in _authorizeUpgrade
        token.upgradeToAndCall(address(impl2), "");
    }
}
