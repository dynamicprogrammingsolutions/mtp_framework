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

   bool delete_after_use;
   ENUM_TRADE_DIRECTION trade_direction;
   ENUM_TRANSACTION_TYPE transaction_type;
   
   COrderCommand()
   {
      delete_after_use = true;
   }
   
   virtual bool DeleteAfterUse() { return delete_after_use; }
   
};