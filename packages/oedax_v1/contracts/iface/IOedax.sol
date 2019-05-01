/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity 0.5.7;


/// @title IOedax
/// @author Daniel Wang  - <daniel@loopring.org>
contract IOedax
{
    address[] auctions;
    // auction_address => auction_id
    mapping (address => uint) auctionIdMap;
    // auction_creator =>  list of his auctions
    mapping (address => address[]) creatorAuctions;

    event AuctionCreated (
        uint    auctionId,
        address auctionAddr
    );

    function transferToken(
        address token,
        address user,
        uint    amount
        )
        public
        returns (bool success);
}
