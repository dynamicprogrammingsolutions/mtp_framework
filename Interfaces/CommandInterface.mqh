//
class CCommandInterface : public CObject
{
public:
   virtual bool DeleteAfterUse() { return false; }   
};