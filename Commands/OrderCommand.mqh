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

class COrderCommand : public CObject
{
public:
   ENUM_TRADE_DIRECTION trade_direction;
   ENUM_TRANSACTION_TYPE transaction_type;
   virtual int Type() const { return classOrderCommand; }
};