// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BSCNS {
    struct Record {
        address owner;
        string domainName;
        uint expirationDate;
    }

    mapping (string => Record) private records;

    mapping (string => Record) private expiredRecords;

    /// @dev check if record is expired and if not listed on expired record list it
    modifier checkIfExpired(string memory _domainName) {
        if(records[_domainName].expirationDate < block.timestamp){
            _;
        } else {
            if(expiredRecords[_domainName].expirationDate == 0) {
                markExpired(_domainName);
                require(1 == 0, "Domain is Expired!");
            }
        }
    }

    /// @dev works as a modifier
    function _checkRecordExist(string memory _domainName) private view returns (bool) {
        if(records[_domainName].owner != address(0)){
            return true;
        } else {
            return false;
        }
    }

    function markExpired(string memory _domainName) public {
        expiredRecords[_domainName] = records[_domainName];
    }

    /// @dev createRecord
    function createRecord(string memory _domainName, uint64 _subscriptionYear) public {
        require(!_checkRecordExist(_domainName), "Record already exists!");
        uint expirationDate = uint(_subscriptionYear * 365 days) + block.timestamp;
        records[_domainName] = Record(msg.sender, _domainName, expirationDate);
    }

    /// @dev record availability will be checked
    function getRecord(string memory _domainName) external view returns (Record memory) {
        return records[_domainName];
    }

    /// @dev transfer ownership
    function transferOwnership(address _newOwner, string memory _domainName) public checkIfExpired(_domainName) {
        require(_checkRecordExist(_domainName), "Record do not exists!");
        require(records[_domainName].owner == msg.sender, "Only domain record owner can transfer ownership!");
        records[_domainName].owner = _newOwner;
    }
    
    /// @dev delete record
    function deleteRecord(string memory _domainName) public {
        if(records[_domainName].expirationDate + 7 days >= block.timestamp || expiredRecords[_domainName].expirationDate + 7 days >= block.timestamp) {
            records[_domainName] = Record(address(0), "", 0);
        }
    }
}