enum ENUM_TRADE_DIRECTION {
   tdNone,
   tdLong,
   tdShort
};

enum ENUM_TRANSACTION_TYPE {
   ttOpen,
   ttClose,
   ttCancel
};

class COrderCommand : public CCommandInterface
{
public:
   virtual int Type() const { return classOrderCommand; }
   
   static int Command;
   
   bool delete_after_use;
   ENUM_TRADE_DIRECTION trade_direction;
   ENUM_TRANSACTION_TYPE transaction_type;
   
   COrderCommand()
   {
      delete_after_use = true;
   }
   
   COrderCommand(ENUM_TRADE_DIRECTION _trade_direction, ENUM_TRANSACTION_TYPE _transaction_type)
   {
      delete_after_use = true;
      trade_direction = _trade_direction;
      transaction_type = _transaction_type;
   }
   
   virtual bool DeleteAfterUse() { return delete_after_use; }
   
};

int COrderCommand::Command = 0;