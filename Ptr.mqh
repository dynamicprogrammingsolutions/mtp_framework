#include "Loader.mqh"

#define PTR_H
template<typename T>

#ifndef ISSET
#define ISSET(__obj__) (CheckPointer(__obj__)!=POINTER_INVALID)
#endif
#ifndef ISNSET
#define ISNSET(__obj__) (CheckPointer(__obj__)==POINTER_INVALID)
#endif

#define UISSET(__obj__) (__obj__!=NULL)
#define UISNSET(__obj__) (__obj__==NULL)

enum ENUM_PTR_TYPE
{
   ptrNone,
   ptrShared,
   ptrUnique,
   ptrWeak
};

template<typename T>
class base_ptr : public CObject
{
protected:
   ENUM_PTR_TYPE ptrtype;
   T *sharedobj;
public:
   base_ptr() : sharedobj(NULL)
   {
      
   }
   
   base_ptr(const base_ptr<T> &ptr)
   {
      ptrtype = ptr.ptrtype;
      if (ptr.isnset()) {
         sharedobj = NULL;
         return;
      }
      sharedobj = ptr.sharedobj;
      switch(ptrtype) {
         case ptrShared:
            sharedobj.RefAdd();
            break;
         case ptrUnique:
            sharedobj.UniqueLock();
            break;
      }     
   }
   
   ~base_ptr()
   {
      /*if (this.isset())
         Print("deinit pointer of type "+EnumToString((ENUM_CLASS_NAMES)sharedobj.Type())+" counter: "+sharedobj.RefCount()+" owned: "+sharedobj.Owned()+" ptrtype: "+EnumToString(ptrtype));
      else
         Print("deinit pointer to NULL");*/
      switch(ptrtype) {
         case ptrUnique:
            if (ISSET(sharedobj)) {
               sharedobj.UniqueRelease();
               sharedobj.UniqueDelete();
            }
            break;
         case ptrShared:
            if (ISSET(sharedobj)) {
               sharedobj.RefDel().RefClean();
            }
            break;
      }
      sharedobj = NULL;
   }
   
   template<typename T1>
   void assign(base_ptr<T1> &ptr)
   {
      switch(ptrtype) {
         case ptrShared:
            if (ptr.isset()) ptr.get().RefAdd();
            if (UISSET(sharedobj)) sharedobj.RefDel().RefClean();
            break;
         case ptrUnique:
            if (UISSET(sharedobj)) sharedobj.UniqueRelease();
            if (ptr.isset()) ptr.get().UniqueLock();
            if (UISSET(sharedobj)) sharedobj.UniqueDelete();
            break;
      }
      sharedobj = ptr.get();
   }
   void reset(T *obj)
   {
      switch(ptrtype) {
         case ptrShared:
            if (ISSET(obj)) obj.RefAdd();
            if (UISSET(sharedobj)) sharedobj.RefDel().RefClean();
            break;
         case ptrUnique:
            if (UISSET(sharedobj)) sharedobj.UniqueRelease();
            if (ISSET(obj)) obj.UniqueLock();
            if (UISSET(sharedobj)) sharedobj.UniqueDelete();
            break;
      }
      if (ISSET(obj)) sharedobj = obj;
      else sharedobj = NULL;
   }
   
   T *detach()
   {
      switch(ptrtype) {
         case ptrShared:
            if (UISSET(sharedobj)) {
               T *temp = sharedobj;
               sharedobj = NULL;
               temp.RefDel();
               return temp;
            } else {
               return NULL;
            }
            break;
         case ptrUnique:
            if (UISSET(sharedobj)) {
               T *temp = sharedobj;
               sharedobj = NULL;
               temp.UniqueRelease();
               return temp;
            } else {
               return NULL;
            }
            break;
         case ptrWeak:
            if (ISSET(sharedobj)) {
               T *temp = sharedobj;
               sharedobj = NULL;
               return temp;
            } else {
               return NULL;
            }
            break;
      }
      return NULL;
   }
   
   int refcount() const
   {
      if (ISSET(sharedobj))
         return sharedobj.RefCount();
      else
         return -1;
   }
   
   bool isset() const
   {
      if (ptrtype != ptrWeak)
         return UISSET(sharedobj);
      else
         return ISSET(sharedobj);
   }
   
   bool isnset() const
   {
      if (ptrtype != ptrWeak)
         return UISNSET(sharedobj);
      else
         return ISNSET(sharedobj);
   }
   
   T *get() const
   {
      if (ptrtype == ptrWeak) {
         if (ISSET(sharedobj)) return sharedobj;
         else return NULL;
      }
      return sharedobj;
   }
   
   virtual bool      Save(const int file_handle)                         
   {
      if (isset())
         return sharedobj.Save(file_handle);
      else
         return true;
   }
   
   virtual bool      Load(const int file_handle)
   {
      if (isset())
         return sharedobj.Load(file_handle);
      else
         return true;
   }

   virtual int       Type(void)
   {
      if (isset())
         return sharedobj.Type();
      else
         return 0;
   }

   virtual int       Compare(const CObject *node,const int mode=0) const
   {
      if (isset())
         return sharedobj.Compare(node,mode);
      else
         return 0;
   }

};

template<typename T>
class shared_ptr : public base_ptr<T>
{
public:
   shared_ptr()
   {
      ptrtype = ptrShared;
   }
   shared_ptr(const base_ptr<T> &ptr)
   {
      ptrtype = ptrShared;
      if (ptr.isset()) {
         sharedobj = ptr.get();
         sharedobj.RefAdd();
      }
   }
   shared_ptr(T *obj)
   {
      ptrtype = ptrShared;
      if (ISSET(obj)) {
         sharedobj = obj;
         sharedobj.RefAdd();
      }
   }
   shared_ptr(T &obj)
   {
      ptrtype = ptrShared;
      sharedobj = GetPointer(obj);
      if (ISSET(sharedobj)) {
         sharedobj.RefAdd();
      } else {
         sharedobj = NULL;
      }  
   }
   template<typename T1>
   static shared_ptr<T> make_shared(T &obj)
   {
      return obj;
   }
   
   static shared_ptr<T> make_shared(T *obj)
   {
      return obj;
   }

   static shared_ptr<T> make_shared()
   {
      return NULL;
   }

   template<typename T1>
   static shared_ptr<T> make_shared(base_ptr<T1> &ptr)
   {
      return ptr.get();
   }

};

template<typename T>
class unique_ptr : public base_ptr<T>
{
public:
   unique_ptr()
   {
      ptrtype = ptrUnique;      
   }
   unique_ptr(const base_ptr<T> &ptr)
   {
      ptrtype = ptrUnique;      
      if (ptr.isset()) {
         sharedobj = ptr.get();
         sharedobj.UniqueLock();
      } else {
         sharedobj = NULL;
      }
   }
   unique_ptr(T *obj)
   {
      ptrtype = ptrUnique;   
      if (ISSET(obj)) {   
         sharedobj = obj;
         sharedobj.UniqueLock();
      }
   }
   unique_ptr(T &obj)
   {
      ptrtype = ptrUnique;      
      sharedobj = GetPointer(obj);
      if (ISSET(sharedobj)) {
         sharedobj.UniqueLock();
      } else {
         sharedobj = NULL;
      }
   }
   static unique_ptr<T> make_unique(T &obj)
   {
      return obj;
   }
   
   static unique_ptr<T> make_unique(T *obj)
   {
      return obj;
   }

   static unique_ptr<T> make_unique()
   {
      return NULL;
   }

   template<typename T1>
   static unique_ptr<T> make_unique(base_ptr<T1> &ptr)
   {
      return ptr.get();
   }

};


template<typename T>
class weak_ptr : public base_ptr<T>
{
public:
   weak_ptr()
   {
      ptrtype = ptrWeak;            
   }
   weak_ptr(const base_ptr<T> &ptr)
   {
      ptrtype = ptrWeak;
      sharedobj = ptr.get();            
   }
   weak_ptr(T *obj)
   {
      ptrtype = ptrWeak;
      if (ISSET(obj))
         sharedobj = obj;
      else
         sharedobj = NULL;
   }
   weak_ptr(T &obj)
   {
      ptrtype = ptrWeak;    
      sharedobj = GetPointer(obj);
      if (ISNSET(sharedobj))
         sharedobj = NULL;
   }
   static weak_ptr<T> make_weak(T &obj)
   {
      return obj;
   }
   
   static weak_ptr<T> make_weak(T *obj)
   {
      return obj;
   }

   static weak_ptr<T> make_weak()
   {
      return NULL;
   }

   template<typename T1>
   static weak_ptr<T> make_weak(base_ptr<T1> &ptr)
   {
      return ptr.get();
   }

};