//
class COrderFactory : public COrderFactoryBase {
public:
   virtual int Type() const { return classOrderFactory; }
protected:
   virtual CAppObject* GetNewObject() { return new COrder(); }
};