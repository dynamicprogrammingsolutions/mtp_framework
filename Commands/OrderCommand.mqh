enum ENUM_ORDER_COMMAND_TYPE {
   commandOpenBuy,
   commandOpenSell,
   commandCloseBuy,
   commandCloseSell,
   commandCloseAll
};

class COrderCommand : public CObject
{
public:
   virtual int Type() const { return classOrderCommand; }
   ENUM_ORDER_COMMAND_TYPE commandtype;
   
   COrderCommand(ENUM_ORDER_COMMAND_TYPE _commandtype)
   {
      commandtype = _commandtype;
   }
   static int Command;
};

int COrderCommand::Command = 0;