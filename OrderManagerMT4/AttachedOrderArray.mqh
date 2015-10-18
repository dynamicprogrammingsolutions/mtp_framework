// *** CAttachedOrderArray ***
//#include "AttachedOrder.mqh"

class CAttachedOrderArray : public CAppObjectArrayObj
{
public:
   virtual int Type() const { return classMT4AttachedOrderArray; }
public:
   CAttachedOrder *AttachedOrder(int nIndex){return((CAttachedOrder*)At(nIndex));}   
   virtual bool  CreateElement(const int index) {
      m_data[index] = new CAttachedOrder(this.AppBase());      
      return(true);
   }
};