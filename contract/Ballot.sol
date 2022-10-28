pragma solidity >=0.7.0 <0.9.0;

contract Ballot {

    struct voter {
        bool voted;
        uint vote;
    }

    struct candidate {
        uint number_of_votes;
        address payable account;
    }

    mapping(address => voter) public voters;

    candidate[] public candidates;

    address public main_contract;

    uint finish_date; //дата окончания 
    uint x; //стоимость участия
    uint f; //комиссия

    constructor() {
        main_contract = msg.sender;
    }

    modifier is_owner{
        if (main_contract == msg.sender) {
            _;
        }
    }

    function check_late_date(uint time) public view {  
        require(block.timestamp >= time, "too late date");
    }

    function check_early_date(uint time) public view {
        require(block.timestamp <= time, "too early date");
    }

    function createVoting(uint d, uint pay, uint fee, address[] memory c) is_owner public {
        require(d > 0, "can't be zero days");
        require(c.length > 0, "need at least 1 candidate");
        finish_date = block.timestamp + (d * 1 days);
        x = pay;
        f = fee;
        for (uint i = 0; i < c.length; i++) {
            candidates.push(
                candidate({
                    account: payable(c[i]), 
                    number_of_votes: 0
                })
            );
        }
    }

    function withdrawFees() is_owner public {
        check_late_date(finish_date);

        uint max_votes = 0;
        uint winners_number = 1;
        uint all_votes = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].number_of_votes > max_votes) {
                max_votes = candidates[i].number_of_votes;
                winners_number = 1;
            } 
            all_votes += candidates[i].number_of_votes;
            if (candidates[i].number_of_votes == max_votes) {
                winners_number += 1;
            }
        }


        uint prize = (x - f) * all_votes / winners_number;
        assert(prize >= 0);

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].number_of_votes == max_votes) {
                candidates[i].account.transfer(prize);
            }
        }

        payable(main_contract).transfer(f * all_votes);
    }

    function voteFor(uint candidateIndex) public payable {
        check_late_date(finish_date);
        require(!voters[msg.sender].voted, "Voter has already voted.");
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = candidateIndex;
        candidates[candidateIndex].number_of_votes += 1;
    }

    function getVoteInfo() public view returns (uint days_to_end, uint pay, uint fee ) {
       days_to_end = (finish_date - block.timestamp) / 60 / 60 / 24 ;
       pay = x;
       fee = f;
    }
}