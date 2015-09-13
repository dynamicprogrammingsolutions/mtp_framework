//
#include "EnumStateselect.mqh"

bool state_placed(ENUM_ORDER_STATE orderstate)
{
   if (orderstate >= ORDER_STATE_PLACED) return(true);
   else return(false);
}

bool state_canceled(ENUM_ORDER_STATE orderstate)
{
   switch (orderstate) {
      case ORDER_STATE_CANCELED:
      case ORDER_STATE_REJECTED:
      case ORDER_STATE_EXPIRED:
         return(true);
      default:
         return(false);
   }
}

bool state_filled(ENUM_ORDER_STATE orderstate)
{
   switch (orderstate) {
      case ORDER_STATE_PARTIAL:
      case ORDER_STATE_FILLED:
         return(true);
      default:
         return(false);
   }
}

bool state_undone(ENUM_ORDER_STATE orderstate)
{
   switch (orderstate) {
      case ORDER_STATE_STARTED:
      case ORDER_STATE_PLACED:
         return(true);
      default:
         return(false);
   }
}

bool state_ongoing(ENUM_ORDER_STATE orderstate)
{
   switch (orderstate) {
      case ORDER_STATE_PLACED:
      case ORDER_STATE_FILLED:
         return(true);
      default:
         return(false);
   }
}


bool state_select(ENUM_STATESELECT stateselect, ENUM_ORDER_STATE orderstate) {
   switch (stateselect) {
      case STATESELECT_ANY:
         return(true);
      case STATESELECT_PLACED:
         return(state_placed(orderstate));
      case STATESELECT_CANCELED:
         return(state_canceled(orderstate));
      case STATESELECT_FILLED:
         return(state_filled(orderstate));
      case STATESELECT_UNDONE:
         return(state_undone(orderstate));
      case STATESELECT_ONGOING:
         return(state_ongoing(orderstate));
      default:
         return(false);
   }
}