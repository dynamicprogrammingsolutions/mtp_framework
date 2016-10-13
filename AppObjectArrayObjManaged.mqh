//
#include "Loader.mqh"

#define APP_OBJECT_ARRAY_OBJ_MANAGED_H
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
  /*CObject *CAppObjectArrayObj::At(const int index) const
  {
//--- check
   if(index<0 || index>=m_data_total)
      return(NULL);
//--- result
   return(m_data[index]);
  }*/
   bool Add(CObject *element)
   {
      //return CAppObjectArrayObj::Add(new CSharedPtr<CObject>(element));
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
         if (isset(m_data[i])) ref_del(m_data[i]);
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
            ENUM_CLASS_NAMES type = (ENUM_CLASS_NAMES)FileReadInteger(file_handle,INT_VALUE);
            if(!CreateElement(i)) {
               if (!CreateElement(i,type)) {
                  Print("failed to create element of object type ",EnumToString(type),"using object type ",isset(newelement)?EnumToString((ENUM_CLASS_NAMES)newelement.Type()):"NULL");
                  break;
               }
            }
            ref_add(m_data[i]);
            if(m_data[i].Load(file_handle)!=true) {
               Print("failed to load object type ",EnumToString(type));
               break;
            }
            m_data_total++;
           }
        }
      m_sort_mode=-1;
   //--- result
      return(m_data_total==num);
     }
   //+------------------------------------------------------------------+

   
};