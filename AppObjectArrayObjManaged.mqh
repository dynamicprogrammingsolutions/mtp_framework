//

class CAppObjectArrayObjManaged: public CAppObjectArrayObj
{
public:
   ~CAppObjectArrayObjManaged()
   {
      if(m_data_max!=0)
         Shutdown();
   }
   bool Shutdown(void)
  {
   //--- check
      if(m_data_max==0)
         return(true);
   //--- clean
      Clear();
      if(ArrayResize(m_data,0)==-1)
         return(false);
      m_data_max=0;
   //--- successful
      return(true);
  }
   bool Add(CObject *element)
   {
      ref_add(element);
      return CAppObjectArrayObj::Add(element);
   }
   CObject *Detach(const int index)
   {
      CObject* element = CAppObjectArrayObj::Detach(index);
      ref_del(element);
      return element;
   }
   bool Delete(const int index)
   {
      CObject* element = CAppObjectArrayObj::Detach(index);
      if (CheckPointer(element) == POINTER_INVALID) return false;
      ref_del(element);
      ref_clean(element);
      return true;
   }
   
   void Clear(void)
  {
//--- "physical" removal of the object (if necessary and possible)
      
      for(int i=0;i<m_data_total;i++)
      {
         ref_del(m_data[i]);
         if(m_free_mode)
         {
            if(CheckPointer(m_data[i])==POINTER_DYNAMIC) {
               ref_clean(m_data[i]);
            }
            m_data[i]=NULL;
         }
      }
      m_data_total=0;
  }
  
   virtual bool Load(const int file_handle)
     {
      int i=0,num;
   //--- check
      if(!CAppObjectArray::Load(file_handle))
         return(false);
   //--- read array length
      num=FileReadInteger(file_handle,INT_VALUE);
   //--- read array
      Clear();
      if(num!=0)
        {
         if(!Reserve(num))
            return(false);
         for(i=0;i<num;i++)
           {
            //--- create new element
            if(!CreateElement(i)) {
               break;
            }
            ref_add(m_data[i]);
            if(m_data[i].Load(file_handle)!=true)
               break;
            m_data_total++;
           }
        }
      m_sort_mode=-1;
   //--- result
      return(m_data_total==num);
     }
   //+------------------------------------------------------------------+

   
};