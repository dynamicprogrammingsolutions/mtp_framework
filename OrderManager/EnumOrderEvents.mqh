enum ENUM_ORDER_EVENT {
   ORDER_EVENT_STATE_CHANGE
};

class COrderEventStateChange : public CObject {
private:
   COrderInterface* m_order;
   ENUM_ORDER_STATE m_laststate;
   ENUM_ORDER_STATE m_newstate;
   
public:
   TraitGetType(classOrderEventStateChange)
   COrderEventStateChange(COrderEventStateChange* copy_from) {
      m_order = copy_from.m_order;
      m_laststate = copy_from.m_laststate;
      m_newstate = copy_from.m_newstate;
   }
   COrderEventStateChange(COrderInterface* order, ENUM_ORDER_STATE laststate) {
      m_laststate = laststate;
      m_order = order;
      m_newstate = order.State();
   }
   ENUM_ORDER_STATE GetLastState() {
      return m_laststate;
   }
   ENUM_ORDER_STATE GetNewState() {
      return m_newstate;
   }
   COrderInterface* GetOrder() {
      return m_order;
   }
};