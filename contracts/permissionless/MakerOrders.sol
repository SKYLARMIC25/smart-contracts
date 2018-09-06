pragma solidity 0.4.18;


contract MakerOrders {
    struct FreeOrders {
        uint32 firstOrderId;
        uint32 numOrders; //max is 256
        uint256 takenBitmap;
    }

    function takeOrderId(FreeOrders storage freeOrders)
        internal
        returns(uint32)
    {
        uint numOrders = freeOrders.numOrders;
        uint orderBitmap = freeOrders.takenBitmap;
        uint bitPointer = 1;

        for(uint i = 0; i < numOrders; ++i) {

            if ((orderBitmap & bitPointer) == 0) {
                freeOrders.takenBitmap = orderBitmap | bitPointer;
                return(uint32(uint(freeOrders.firstOrderId) + i));
            }

            bitPointer *= 2;
        }

        require(false);
    }

    /// @dev mark order as free to use.
    function releaseOrderId(FreeOrders storage freeOrders, uint32 orderId)
        internal
        returns(bool)
    {
        require(orderId >= freeOrders.firstOrderId);
        require(orderId < (freeOrders.firstOrderId + freeOrders.numOrders));

        uint orderBitNum = uint(orderId) - uint(freeOrders.firstOrderId);
        uint256 bitPointer = 1 * (2 ** orderBitNum);
        // TODO: enable!
        //        require(bitPointer & freeOrders.takenBitmap == 1);

        uint256 bitNegation = bitPointer ^ 0xffffffffffffffff;

        freeOrders.takenBitmap &= bitNegation;
    }

    function allocateOrders(
        FreeOrders storage freeOrders,
        uint32 firstAllocatedId,
        uint32 howMany
    )
        internal
        returns(bool)
    {
        require(howMany <= 256);

        if (freeOrders.takenBitmap != 0) return true;
        if (howMany == freeOrders.numOrders) return true;

        // make sure no orders in use at the moment
        require(freeOrders.takenBitmap == 0);

        freeOrders.firstOrderId = firstAllocatedId;
        freeOrders.numOrders = howMany;
        freeOrders.takenBitmap = 0;

        return true;
    }
}