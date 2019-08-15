pragma solidity 0.4.26;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
	/**
 	* @dev Returns the addition of two unsigned integers, reverting on
 	* overflow.
 	*
 	* Counterpart to Solidity's `+` operator.
 	*
 	* Requirements:
 	* - Addition cannot overflow.
 	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
    	uint256 c = a + b;
    	require(c >= a, "SafeMath: addition overflow");

    	return c;
	}

	/**
 	* @dev Returns the subtraction of two unsigned integers, reverting on
 	* overflow (when the result is negative).
 	*
 	* Counterpart to Solidity's `-` operator.
 	*
 	* Requirements:
 	* - Subtraction cannot overflow.
 	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    	require(b <= a, "SafeMath: subtraction overflow");
    	uint256 c = a - b;

    	return c;
	}

	/**
 	* @dev Returns the multiplication of two unsigned integers, reverting on
 	* overflow.
 	*
 	* Counterpart to Solidity's `*` operator.
 	*
 	* Requirements:
 	* - Multiplication cannot overflow.
 	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    	// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    	// benefit is lost if 'b' is also tested.
    	// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    	if (a == 0) {
        	return 0;
    	}

    	uint256 c = a * b;
    	require(c / a == b, "SafeMath: multiplication overflow");

    	return c;
	}

	/**
 	* @dev Returns the integer division of two unsigned integers. Reverts on
 	* division by zero. The result is rounded towards zero.
 	*
 	* Counterpart to Solidity's `/` operator. Note: this function uses a
 	* `revert` opcode (which leaves remaining gas untouched) while Solidity
 	* uses an invalid opcode to revert (consuming all remaining gas).
 	*
 	* Requirements:
 	* - The divisor cannot be zero.
 	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
    	// Solidity only automatically asserts when dividing by 0
    	require(b > 0, "SafeMath: division by zero");
    	uint256 c = a / b;
    	// assert(a == b * c + a % b); // There is no case in which this doesn't hold

    	return c;
	}

	/**
 	* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
 	* Reverts when dividing by zero.
 	*
 	* Counterpart to Solidity's `%` operator. This function uses a `revert`
 	* opcode (which leaves remaining gas untouched) while Solidity uses an
 	* invalid opcode to revert (consuming all remaining gas).
 	*
 	* Requirements:
 	* - The divisor cannot be zero.
 	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    	require(b != 0, "SafeMath: modulo by zero");
    	return a % b;
	}
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// @title Super Simple Smart Wallet for 2/3 MultiSignature Ether Transfers (Ξ)
// @author R. Ross Campbell

contract SSSWallet {
    using SafeMath for uint256;

    address public signer1;
    address public signer2;
    address public signer3;

    address public transferee;
    uint256 public amount;
    address public tokenContract;
    string public details;
    
    string public proposal;
    
    address private lockedSigner;

    enum State { Initialized, Proposed }
	State public state;

    mapping(address => uint256) public signatures;

    event Received(address from, uint256 amount);  
    event EtherTransferProposed(address indexed transferee, uint256 amount, string details);
    event EtherTransferConfirmed();
    event TokenTransferProposed(address indexed transferee, uint256 amount, string details);
    event TokenTransferConfirmed();
    event proposalSubmitted(string indexed proposal);
    event proposalSigned();
    event signatureUnlocked(address indexed lockedSigner);

constructor(address _signer1, address _signer2, address _signer3) public {
    signer1 = _signer1;
    signer2 = _signer2;
    signer3 = _signer3;
    signatures[_signer1] = 1;
    signatures[_signer2] = 1;
    signatures[_signer3] = 1;
  }

modifier inState(State _state) {
        require(state == _state);
    	_;
  }
  
// keep all the ether sent to this address
function() payable public {
    emit Received(msg.sender, msg.value);
  }

function isSignerwithSignatures(address x) public view returns (bool) {
    return signatures[x] > 0;
  }
  
function submitProposal(string _proposal) public {
    require(isSignerwithSignatures(msg.sender));
    state = State.Proposed;
    proposal = _proposal;
    signatures[msg.sender] = signatures[msg.sender].sub(1);
    lockedSigner = msg.sender;
    emit proposalSubmitted(proposal);
  }
  
function signProposal() public inState(State.Proposed) {
    require(isSignerwithSignatures(msg.sender));
    state = State.Initialized;
    signatures[lockedSigner] = signatures[lockedSigner].add(1); 
    proposal = "signed";
    emit proposalSigned();
    emit signatureUnlocked(lockedSigner);
  }
  
function proposeEtherTransfer(address _transferee, uint256 _amount, string memory _details) public {
    require(isSignerwithSignatures(msg.sender));
    state = State.Proposed;
    transferee = _transferee;
    amount = _amount;
    details = _details;
    signatures[msg.sender] = signatures[msg.sender].sub(1);
    lockedSigner = msg.sender;
    emit EtherTransferProposed(transferee, amount, details);
  } 
  
function proposeTokenTransfer(address _transferee, uint256 _amount, address _tokenContract, string memory _details) public {
    require(isSignerwithSignatures(msg.sender));
    state = State.Proposed;
    transferee = _transferee;
    amount = _amount;
    tokenContract = _tokenContract;
    details = _details;
    signatures[msg.sender] = signatures[msg.sender].sub(1);
    lockedSigner = msg.sender;
    emit TokenTransferProposed(transferee, amount, details);
  }
  
function signEtherTransfer() public inState(State.Proposed) {
    require(isSignerwithSignatures(msg.sender));
    state = State.Initialized;
    signatures[lockedSigner] = signatures[lockedSigner].add(1); 
    transferee.transfer(amount);
    emit EtherTransferConfirmed();
    emit signatureUnlocked(lockedSigner);
  }
  
function signTokenTransfer() public inState(State.Proposed) {
    require(isSignerwithSignatures(msg.sender));
    //now send the proposed token transfer amount
    IERC20(tokenContract).transfer(transferee, amount);
    state = State.Initialized;
    signatures[lockedSigner] = signatures[lockedSigner].add(1); 
    emit TokenTransferConfirmed();
    emit signatureUnlocked(lockedSigner);
  }
}
