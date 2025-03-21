// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract Factory {

    struct UserInfo {
        address contractAddress;
        bool exists;
    }

    struct GroupInfo {
        address contractAddress;
        bool exists;
    }
    
    
    mapping(address => UserInfo) public users;
    mapping(uint256 => GroupInfo) public groups;

    uint256 public groupCounter;


    function registerUser(string memory publicKey, string memory encryptedPrivateKey) external {
        require(!users[msg.sender].exists, "User already registered");
        
        UserContract newUserContract = new UserContract(msg.sender, publicKey, encryptedPrivateKey);
        users[msg.sender] = UserInfo(address(newUserContract), true);

    }

    function createGroup(string memory groupPublicKey, string memory encryptedGroupPrivateKey) external {
        require(users[msg.sender].exists, "User not registered");
        groupCounter++;
        GroupChat newGroup = new GroupChat(msg.sender, groupCounter, groupPublicKey, encryptedGroupPrivateKey);
        groups[groupCounter] = GroupInfo(address(newGroup), true);


    }

    function getGroupContract(uint256 groupId) external view returns (address) {
        require(groups[groupId].exists, "Group not found");
        return groups[groupId].contractAddress;
    }
    
    function getUserContract(address user) external view returns (address) {
        require(users[user].exists, "User not registered");
        return users[user].contractAddress;
    }
}

contract UserContract {
    address public owner;
    string public publicKey;
    string private encryptedPrivateKey;

    struct Message {
        string encryptedContent;
        uint256 timestamp;     
        bool isRead;
    }
    
    mapping(address => Message[]) private userMessages;
    event MessageReceived(address indexed sender, string encryptedContent);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    constructor(address _owner, string memory _publicKey, string memory _encryptedPrivateKey) {
        owner = _owner;
        publicKey = _publicKey;
        encryptedPrivateKey = _encryptedPrivateKey;
    }
    
    function sendMessage(string memory encryptedMessage) external {
        userMessages[msg.sender].push(Message(encryptedMessage, block.timestamp, false));
        emit MessageReceived(msg.sender, encryptedMessage);
    }
    
    function getMessagesBySender(address sender) external view onlyOwner returns (Message[] memory) {
        return userMessages[sender];
    }

    function getEncryptedPrivateKey() external view onlyOwner returns (string memory) {
        return encryptedPrivateKey;
    }

    function markMessageAsRead(address sender, uint index) external onlyOwner {
        require(index < userMessages[sender].length, "Invalid message index");
        require(!userMessages[sender][index].isRead, "Message already read");
        
        userMessages[sender][index].isRead = true;
    }
}
contract GroupChat {
    address public admin;
    uint256 public groupId;
    string public groupPublicKey;
    string private encryptedGroupPrivateKeyByAdmin;

    struct Member {
        string publicKey;
        string encryptedGroupPrivateKeyByMem;
        bool exists;
    }

    struct Message {
        address sender;
        string encryptedContent;
        uint256 timestamp;
    }

    mapping(address => Member) public members;
    Message[] public messages;

    event MemberAdded(address indexed member);
    event MessageSent(address indexed sender, string encryptedContent, uint256 timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the admin");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender].exists, "Not a group member");
        _;
    }

    constructor(address _admin, uint256 _groupId, string memory _groupPublicKey, string memory _encryptedGroupPrivateKey) {
        admin = _admin;
        groupId = _groupId;
        groupPublicKey = _groupPublicKey;
        encryptedGroupPrivateKeyByAdmin = _encryptedGroupPrivateKey;
        
        // Thêm admin vào danh sách thành viên
        members[_admin] = Member(_groupPublicKey,_encryptedGroupPrivateKey, true);
    }

    function addMember(address user, string memory userPublicKey, string memory encryptedGroupPrivateKeyByMem) external onlyAdmin {
        require(!members[user].exists, "User already a member");
        members[user] = Member(userPublicKey,encryptedGroupPrivateKeyByMem, true);
        emit MemberAdded(user);
    }

    function sendMessage(string memory encryptedMessage) external onlyMember {
        messages.push(Message(msg.sender, encryptedMessage, block.timestamp));
        emit MessageSent(msg.sender, encryptedMessage, block.timestamp);
    }

    function getMessages() external view onlyMember returns (Message[] memory) {
        return messages;
    }

    function getEncryptedGroupPrivateKey() external view onlyAdmin returns (string memory) {
        return encryptedGroupPrivateKeyByAdmin;
    }
}
