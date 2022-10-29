// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ballot {

    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    struct Proposal{
        bytes32 name;
        uint voteCount;
    }

    modifier onlyChairperson{
        require(msg.sender==chairperson, "Only chairperson can call this function");
        _;
    }

    address public chairperson;

    mapping(address=>Voter) public voters;

    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight=1;

        for(uint i=0;i<proposalNames.length;i++){
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function giveRightToVote(address voter) onlyChairperson public {
        require(!voters[voter].voted,"Already Voted, Cannot vote again");
        require(voters[voter].weight==0);

        voters[voter].weight=1;
    }

    function delegate(address to) public{
        Voter memory sender = voters[msg.sender];
        require(!sender.voted,"Not already voted");
        require(to!=msg.sender,"Cant delegate self");

        sender.voted=true;
        sender.delegate=to;

        Voter memory _delegate = voters[to];
        if(_delegate.voted){
            proposals[_delegate.vote].voteCount+=sender.weight;
        }
        else{
            _delegate.weight+=sender.weight;
        }
    }

    function vote(uint proposal) public {
        Voter memory sender = voters[msg.sender];
        require(!sender.voted);
        require(sender.weight!=0);

        sender.voted=true;
        sender.vote=proposal;

        proposals[proposal].voteCount+=sender.weight;
    } 

    function winningProposal() public view returns(uint winner){
        uint max=0;
        for(uint i=0;i<proposals.length;i++){
            if(proposals[i].voteCount>max){
                max=proposals[i].voteCount;
                winner=i;
            }
        }
    }

}