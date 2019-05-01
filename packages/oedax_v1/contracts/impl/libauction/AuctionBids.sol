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
pragma experimental ABIEncoderV2;

import "../../iface/IAuctionData.sol";

import "../../lib/MathUint.sol";

import "./AuctionInfo.sol";
import "./AuctionBalance.sol";
import "./AuctionQueue.sol";

/// @title AuctionAsks.
/// @author Daniel Wang  - <daniel@loopring.org>
library AuctionBids
{
    using MathUint          for uint;
    using MathUint          for uint32;
    using AuctionInfo       for IAuctionData.State;
    using AuctionBalance    for IAuctionData.State;
    using AuctionQueue      for IAuctionData.State;

    event Bid(
        address user,
        uint    amount,
        uint    amountQueued,
        uint    time
    );

    function bid(
        IAuctionData.State storage s,
        uint amount
        )
        internal
        returns(
            uint  _amount,
            uint  _queued,
            IAuctionData.Info memory i
        )
    {
        require(amount > 0, "zero amount");
         _amount = amount;

        // calculate the current-state
        i = s.getAuctionInfo();

        if (i.additionalBidAmountAllowed < _amount) {
            _queued = _amount.sub(i.additionalBidAmountAllowed);
            _amount = i.additionalBidAmountAllowed;
        }

        if (_queued > 0) {
            if (s.queueAmount > 0) {
                if (s.queueIsBid) {
                    // Before this BID, the queue is for BIDs
                    assert(_amount == 0);
                } else {
                    // Before this BID, the queue is for ASKs, therefore we must have
                    // consumed all the pending ASKs in the queue.
                    assert(_amount > 0);
                    s.dequeue(s.queueAmount);
                }
            }
            s.queueIsBid = true;
            s.enqueue(_queued);
        } else {
            assert(s.queueAmount == 0 || !s.queueIsBid);
            assert(_amount > 0);
            s.dequeue(s.getQueueConsumption(_amount, s.queueAmount));
        }

        // calculate the post-participation state
        i = s.getAuctionInfo();

        emit Bid(
            msg.sender,
            _amount,
            _queued,
            block.timestamp
        );
    }


}