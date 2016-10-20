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
   ENUM_PTR_TYPE m_ptrtype;
   T *sharedobj;
   
   bool check_new_object(T *obj)
   {
      switch(m_ptrtype) {
         case ptrShared:
            if (CheckPointer(obj) == POINTER_AUTOMATIC) {
               EWarning(Conc("shared_ptr initalized from already managed builtin object: ",CLASS_NAME(obj)));
            }
            if (obj.Owned()) {
               EError(Conc("shared_ptr initalized from owned object ",CLASS_NAME(obj)));
               return false;
            }
            return true;
            break;
         case ptrUnique:
            if (CheckPointer(obj) == POINTER_AUTOMATIC) {
               EWarning(Conc("unique_ptr initalized from already managed builtin object: ",CLASS_NAME(obj)));
            }
            if (obj.Owned()) {
               EError(Conc("unique_ptr initalized from owned object ",CLASS_NAME(obj)));
               return false;
            }
            if (obj.RefCount()) {
               EError(Conc("unique_ptr initalized from shared object ",CLASS_NAME(obj)));
               return false;
            }
            return true;
            break;
         default:
            return true;
      }
   }
   
public:
   base_ptr() : sharedobj(NULL)
   {
      
   }
   
   ~base_ptr()
   {
      switch(m_ptrtype) {
         case ptrUnique:
            if (UISSET(sharedobj)) {
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
      T1 *obj = NULL;
      switch(m_ptrtype) {
         case ptrShared:
            if (ptr.isset()) obj = ptr.get();
            if (obj != NULL) {
               if (!check_new_object(obj)) obj = NULL;
               else obj.RefAdd();
            }
            if (UISSET(sharedobj)) sharedobj.RefDel().RefClean();
            sharedobj = obj;
            break;
         case ptrUnique:
            if (ptr.isset()) obj = ptr.get();
            if (UISSET(sharedobj)) sharedobj.UniqueRelease();
            if (obj != NULL) {
               if (!check_new_object(obj)) obj = NULL;
               else obj.UniqueLock();
            }
            if (UISSET(sharedobj)) sharedobj.UniqueDelete();
            sharedobj = obj;
            break;
         case ptrWeak:
            sharedobj = ptr.get();
            break;
      }
   }
   void reset(T *obj)
   {
      switch(m_ptrtype) {
         case ptrShared:
            if (!ISSET(obj)) obj = NULL;
            if (obj != NULL) {
               if (!check_new_object(obj)) obj = NULL;
               else obj.RefAdd();
            }
            if (UISSET(sharedobj)) sharedobj.RefDel().RefClean();
            sharedobj = obj;
            break;
         case ptrUnique:
            if (!ISSET(obj)) obj = NULL;
            if (UISSET(sharedobj)) sharedobj.UniqueRelease();
            if (obj != NULL) {
               if (!check_new_object(obj)) obj = NULL;
               else obj.UniqueLock();
            }
            if (UISSET(sharedobj)) sharedobj.UniqueDelete();
            sharedobj = obj;
            break;
         case ptrWeak:
            if (ISSET(obj)) sharedobj = obj;
            else sharedobj = NULL;
            break;            
      }
   }
   
   T *detach()
   {
      T *temp;
      switch(m_ptrtype) {
         case ptrShared:
            if (UISSET(sharedobj)) {
               temp = sharedobj;
               sharedobj = NULL;
               temp.RefDel();
               return temp;
            } else {
               return NULL;
            }
            break;
         case ptrUnique:
            if (UISSET(sharedobj)) {
               temp = sharedobj;
               sharedobj = NULL;
               temp.UniqueRelease();
               return temp;
            } else {
               return NULL;
            }
            break;
         case ptrWeak:
            if (ISSET(sharedobj)) {
               temp = sharedobj;
               sharedobj = NULL;
               return temp;
            } else {
               return NULL;
            }
            break;
      }
      return NULL;
   }
   
   ENUM_PTR_TYPE ptrtype() const
   {
      return m_ptrtype;
   }
   
   int refcount() const
   {
      if (ISSET(sharedobj))
         return sharedobj.RefCount();
      else
         return 0;
   }
   
   bool owned() const
   {
      if (ISSET(sharedobj))
         return sharedobj.Owned();
      else
         return false;
   }
   
   bool isset() const
   {
      return ISSET(sharedobj);
   }
   
   bool isnset() const
   {
      return ISNSET(sharedobj);
   }
   
   T *get() const
   {
      if (m_ptrtype == ptrWeak) {
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

/* weak_ptr can be safely initalized from any type of object or ptr
 * use it for weak reference to builtin objects (not pointers, automatically managed), shared_ptr, unique_ptr
 */

template<typename T>
class weak_ptr : public base_ptr<T>
{
public:
   weak_ptr()
   {
      m_ptrtype = ptrWeak;            
   }
   weak_ptr(const base_ptr<T> &ptr)
   {
      m_ptrtype = ptrWeak;
      sharedobj = ptr.get();            
   }
   weak_ptr(T *obj)
   {
      m_ptrtype = ptrWeak;
      if (ISSET(obj))
         sharedobj = obj;
      else
         sharedobj = NULL;
   }
   weak_ptr(T &obj)
   {
      m_ptrtype = ptrWeak;    
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

/* shared_ptr can be safely initalized from : shared_ptr, builtin pointer
 * do not initalize from: weak_ptr, unique_ptr, builtin object
 */

template<typename T>
class shared_ptr : public base_ptr<T>
{
public:
   shared_ptr()
   {
      m_ptrtype = ptrShared;
   }
   shared_ptr(const shared_ptr<T> &ptr)
   {
      m_ptrtype = ptrShared;
      if (ptr.isset()) {
         sharedobj = ptr.get();
         sharedobj.RefAdd();
      }
   }
   shared_ptr(const weak_ptr<T> &ptr)
   {
      m_ptrtype = ptrShared;
      if (ptr.isset()) {
         T *obj = ptr.get();
         if (!check_new_object(obj)) return;
         sharedobj = ptr.get();
         sharedobj.RefAdd();
      }
   }
   shared_ptr(T *obj)
   {
      m_ptrtype = ptrShared;
      if (ISSET(obj) && check_new_object(obj)) {
         sharedobj = obj;
         sharedobj.RefAdd();
      }
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
   static shared_ptr<T> make_shared(shared_ptr<T1> &ptr)
   {
      return ptr.get();
   }

   template<typename T1>
   static shared_ptr<T> make_shared(weak_ptr<T1> &ptr)
   {
      return ptr.get();
   }

};

/* unique_ptr can be safely initalized from : builtin pointer not owned by unique_ptr
 * it is not safe to initalize from: unique_ptr, shared_ptr, weak_ptr, builtin object
 */

template<typename T>
class unique_ptr : public base_ptr<T>
{
public:
   unique_ptr()
   {
      m_ptrtype = ptrUnique;      
   }
   unique_ptr(const weak_ptr<T> &ptr)
   {
      m_ptrtype = ptrUnique;
      if (ptr.isset()) {
         T *obj = ptr.get();
         if (!check_new_object(obj)) return;
         sharedobj = obj;
         sharedobj.UniqueLock();         
      }   
   }
   unique_ptr(T *obj)
   {
      m_ptrtype = ptrUnique;   
      if (ISSET(obj) && check_new_object(obj)) {   
         sharedobj = obj;
         sharedobj.UniqueLock();
      }
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
   static unique_ptr<T> make_unique(weak_ptr<T1> &ptr)
   {
      return ptr.get();
   }

};

