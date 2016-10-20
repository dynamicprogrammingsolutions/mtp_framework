#include "Loader.mqh"

#define ARRAY_OBJECT_H
template<typename T>
class CArrayObject : public CAppObjectArray
{
protected:
   shared_ptr<T> *m_data[];           // data array
   CAppObject *newelement;
   int foreach_index;
   int foreach_cachemax;
public:
                     CArrayObject(void);
                    ~CArrayObject(void);
   //--- method of identifying the object
   virtual int       Type(void) const { return(classAppObjectArrayObj); }
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //--- method of creating an element of array
   virtual void      NewElement(CAppObject* obj) { newelement = obj; }
   virtual bool      CreateElement(const int index) { return(false); }
   virtual bool      CreateElement(const int index, const ENUM_CLASS_NAMES type);
   //--- methods of managing dynamic memory
   bool              Reserve(const int size);
   bool              Resize(const int size);
   bool              Shutdown(void);
   //--- methods of filling the array
   bool              Add(T *element);
   
   template<typename T1>
   bool AddArray(const CArrayObject<T1> *src)
     {
      int num;
   //--- check
      if(!CheckPointer(src))
         return(false);
   //--- check/reserve elements of array
      num=src.Total();
      if(!Reserve(num))
         return(false);
   //--- add
      for(int i=0;i<num;i++)
         m_data[m_data_total++]=new shared_ptr<T>(src.At(i));
      m_sort_mode=-1;
   //--- successful
      return(true);
     }
  
   bool              Insert(T *element,const int pos);
   bool              InsertArray(const CArrayObject *src,const int pos);
   bool              AssignArray(const CArrayObject *src);
   //--- method of access to thre array
   T          *At(const int index) const;
   //--- methods of changing
   bool              Update(const int index,T *element);
   bool              Shift(const int index,const int shift);
   //--- methods of deleting
   T                 *Detach(const int index);
   bool              Delete(const int index);
   bool              DeletePosition(const int index);
   bool              DeleteRange(int from,int to);
   void              Clear(void);
   //--- method for comparing arrays
   bool              CompareArray(const CArrayObject *Array) const;
   //--- methods for working with the sorted array
   bool              InsertSort(T *element);
   int               Search(const T *element) const;
   int               SearchGreat(const T *element) const;
   int               SearchLess(const T *element) const;
   int               SearchGreatOrEqual(const T *element) const;
   int               SearchLessOrEqual(const T *element) const;
   int               SearchFirst(const T *element) const;
   int               SearchLast(const T *element) const;
   
   template<typename IT>
   bool ForEach(IT *&item)
   {
      if (foreach_index == 0) {
         foreach_cachemax = Total();
      }
      if (foreach_index != foreach_cachemax) {
         if (isset(this.At(foreach_index))) {
            item = this.At(foreach_index);
         } else {
            item = NULL;
         }
         foreach_index++;
         return true;
      } else {
         foreach_index = 0;
         return false;
      }
   }
   
   template<typename IT>
   bool ForEachBackward(IT *&item)
   {
      if (foreach_index == 0) {
         foreach_cachemax = Total();
      }
      if (foreach_index != foreach_cachemax) {
         if (isset(this.At(foreach_cachemax-foreach_index))) {
            item = this.At(foreach_cachemax-foreach_index);
            foreach_index++;
            return true;
         } else {
            return false;
         }
      } else {
         foreach_index = 0;
         return false;
      }
   }
   
   template<typename IT>
   bool ForEach(IT *&item, int &index)
   {
      if (index == 0) {
         foreach_cachemax = Total();
      }
      if (index != foreach_cachemax) {
         if (isset(this.At(index))) {
            item = this.At(index);
            index++;
            return true;
         } else {
            return false;
         }
      } else {
         index = 0;
         return false;
      }
   }

protected:
   void              QuickSort(int beg,int end,const int mode);
   int               QuickSearch(const T *element) const;
   int               MemMove(const int dest,const int src,const int count);
  };
  
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
template<typename T>
CArrayObject::CArrayObject(void)
  {
//--- initialize protected data
   m_data_max=ArraySize(m_data);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
template<typename T>
CArrayObject::~CArrayObject(void)
  {
   if(m_data_max!=0)
      Shutdown();
   delete newelement;
  }
//+------------------------------------------------------------------+
//| Moving the memory within a single array                          |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::MemMove(const int dest,const int src,const int count)
  {
   int i;
//--- check
   if(dest<0 || src<0 || count<0)
      return(-1);
   if(dest+count>m_data_total)
     {
      if(Available()<dest+count)
         return(-1);
      m_data_total=dest+count;
     }
//--- no need to copy
   if(dest==src || count==0)
      return(dest);
//--- copy
   if(dest<src)
     {
      //--- copy from left to right
      for(i=0;i<count;i++)
        {
         //--- "physical" removal of the object (if necessary and possible)
         if(/*m_free_mode && */CheckPointer(m_data[dest+i])==POINTER_DYNAMIC)
            delete m_data[dest+i];
         //---
         m_data[dest+i]=m_data[src+i];
         m_data[src+i]=NULL;
        }
     }
   else
     {
      //--- copy from right to left
      for(i=count-1;i>=0;i--)
        {
         //--- "physical" removal of the object (if necessary and possible)
         if(/*m_free_mode && */CheckPointer(m_data[dest+i])==POINTER_DYNAMIC)
            delete m_data[dest+i];
         //---
         m_data[dest+i]=m_data[src+i];
         m_data[src+i]=NULL;
        }
     }
//--- successful
   return(dest);
  }
//+------------------------------------------------------------------+
//| Request for more memory in an array. Checks if the requested     |
//| number of free elements already exists; allocates additional     |
//| memory with a given step                                         |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Reserve(const int size)
  {
   int new_size;
//--- check
   if(size<=0)
      return(false);
//--- resize array
   if(Available()<size)
     {
      new_size=m_data_max+m_step_resize*(1+(size-Available())/m_step_resize);
      if(new_size<0)
         //--- overflow occurred when calculating new_size
         return(false);
      if((m_data_max=ArrayResize(m_data,new_size))==-1)
         m_data_max=ArraySize(m_data);
      //--- explicitly zeroize all the loose items in the array
      for(int i=m_data_total;i<m_data_max;i++)
         m_data[i]=NULL;
     }
//--- result
   return(Available()>=size);
  }
//+------------------------------------------------------------------+
//| Resizing (with removal of elements on the right)                 |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Resize(const int size)
  {
   int new_size;
//--- check
   if(size<0)
      return(false);
//--- resize array
   new_size=m_step_resize*(1+size/m_step_resize);
   if(m_data_total>size)
     {
      //--- "physical" removal of the object (if necessary and possible)
      //if(m_free_mode)
         for(int i=size;i<m_data_total;i++)
            if(CheckPointer(m_data[i])==POINTER_DYNAMIC)
               delete m_data[i];
      m_data_total=size;
     }
   if(m_data_max!=new_size)
     {
      if((m_data_max=ArrayResize(m_data,new_size))==-1)
        {
         m_data_max=ArraySize(m_data);
         return(false);
        }
     }
//--- result
   return(m_data_max==new_size);
  }
//+------------------------------------------------------------------+
//| Complete cleaning of the array with the release of memory        |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Shutdown(void)
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
//+------------------------------------------------------------------+
//| Adding an element to the end of the array                        |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Add(T *element)
  {
//--- check
   /*if(!CheckPointer(element))
      return(false);*/
//--- check/reserve elements of array
   if(!Reserve(1))
      return(false);
//--- add
   m_data[m_data_total++]=new shared_ptr<T>(element);
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Adding an element to the end of the array from another array     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Inserting an element in the specified position                   |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Insert(T *element,const int pos)
  {
//--- check
   if(pos<0 || !CheckPointer(element))
      return(false);
//--- check/reserve elements of array
   if(!Reserve(1))
      return(false);
//--- insert
   m_data_total++;
   if(pos<m_data_total-1)
     {
      MemMove(pos+1,pos,m_data_total-pos-1);
      m_data[pos]=new shared_ptr<T>(element);
     }
   else
      m_data[m_data_total-1]=new shared_ptr<T>(element);
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Inserting elements in the specified position                     |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::InsertArray(const CArrayObject *src,const int pos)
  {
   int num;
//--- check
   if(!CheckPointer(src))
      return(false);
//--- check/reserve elements of array
   num=src.Total();
   if(!Reserve(num)) return(false);
//--- insert
   MemMove(num+pos,pos,m_data_total-pos);
   for(int i=0;i<num;i++)
      m_data[i+pos]=src.m_data[i];
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Assignment (copying) of another array                            |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::AssignArray(const CArrayObject *src)
  {
   int num;
//--- check
   if(!CheckPointer(src))
      return(false);
//--- check/reserve elements of array
   num=src.m_data_total;
   Clear();
   if(m_data_max<num)
     {
      if(!Reserve(num))
         return(false);
     }
   else
      Resize(num);
//--- copy array
   for(int i=0;i<num;i++)
     {
      m_data[i]=src.m_data[i];
      m_data_total++;
     }
   m_sort_mode=src.SortMode();
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Access to data in the specified position                         |
//+------------------------------------------------------------------+
template<typename T>
T *CArrayObject::At(const int index) const
  {
//--- check
   if(index<0 || index>=m_data_total || m_data[index] == NULL)
      return(NULL);
//--- result
   return(m_data[index].get());
  }
//+------------------------------------------------------------------+
//| Updating element in the specified position                       |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Update(const int index,T *element)
  {
//--- check
   if(index<0 || CheckPointer(element) == POINTER_INVALID || index>=m_data_max)
      return(false);
//--- "physical" removal of the object (if necessary and possible)
   if(/*m_free_mode && */CheckPointer(m_data[index])!=POINTER_INVALID)
      m_data[index].reset(element);
   else
      m_data[index] = new shared_ptr<T>(element);
   m_sort_mode=-1;
   m_data_total = MathMax(m_data_total,index+1);
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving element from the specified position                       |
//| on the specified shift                                           |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Shift(const int index,const int shift)
  {
   shared_ptr<T> *tmp_node;
//--- check
   if(index<0 || index+shift<0 || index+shift>=m_data_total)
      return(false);
   if(shift==0)
      return(true);
//--- move
   tmp_node=m_data[index];
   m_data[index]=NULL;
   if(shift>0)
      MemMove(index,index+1,shift);
   else
      MemMove(index+shift+1,index+shift,-shift);
   m_data[index+shift]=tmp_node;
   m_sort_mode=-1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Deleting element from the specified position                     |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Delete(const int index)
  {
//--- check
   if(index>=m_data_total)
      return(false);
//--- delete
   if(index<m_data_total-1)
     {
      if(index>=0)
         MemMove(index,index+1,m_data_total-index-1);
     }
   else if(/*m_free_mode && */CheckPointer(m_data[index])==POINTER_DYNAMIC)
      delete m_data[index];
   m_data_total--;
//--- successful
   return(true);
  }
  
template<typename T>
bool CArrayObject::DeletePosition(const int index)
  {
//--- check
   if(index>=m_data_total)
      return(false);
//--- delete
   if (CheckPointer(m_data[index])==POINTER_DYNAMIC)
      m_data[index].reset(NULL);
//--- successful
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Detach element from the specified position                       |
//+------------------------------------------------------------------+
template<typename T>
T *CArrayObject::Detach(const int index)
  {
   T *result;
//--- check
   if(index>=m_data_total)
      return(NULL);
//--- detach
   result=m_data[index].detach();
//--- reset the array element, so as not remove the method MemMove
   delete m_data[index];
   if(index<m_data_total-1)
      MemMove(index,index+1,m_data_total-index-1);
   m_data_total--;
//--- successful
   return(result);
  }
//+------------------------------------------------------------------+
//| Deleting range of elements                                       |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::DeleteRange(int from,int to)
  {
//--- check
   if(from<0 || to<0)
      return(false);
   if(from>to || from>=m_data_total)
      return(false);
//--- delete
   if(to>=m_data_total-1)
      to=m_data_total-1;
   MemMove(from,to+1,m_data_total-to-1);
   for(int i=to-from+1;i>0;i--,m_data_total--)
      if(/*m_free_mode && */CheckPointer(m_data[m_data_total-1])==POINTER_DYNAMIC)
         delete m_data[m_data_total-1];
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Clearing of array without the release of memory                  |
//+------------------------------------------------------------------+
template<typename T>
void CArrayObject::Clear(void)
  {
//--- "physical" removal of the object (if necessary and possible)
   //if(m_free_mode)
     {
      for(int i=0;i<m_data_total;i++)
        {
         if(CheckPointer(m_data[i])==POINTER_DYNAMIC)
            delete m_data[i];
         m_data[i]=NULL;
        }
     }
   m_data_total=0;
  }
//+------------------------------------------------------------------+
//| Equality comparison of two arrays                                |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::CompareArray(const CArrayObject *Array) const
  {
//--- check
   if(!CheckPointer(Array))
      return(false);
//--- compare
   if(m_data_total!=Array.m_data_total)
      return(false);
   for(int i=0;i<m_data_total;i++)
      if(m_data[i].Compare(Array.m_data[i],0)!=0)
         return(false);
//--- equal
   return(true);
  }
//+------------------------------------------------------------------+
//| Method QuickSort                                                 |
//+------------------------------------------------------------------+
template<typename T>
void CArrayObject::QuickSort(int beg,int end,const int mode)
  {
   int      i,j;
   shared_ptr<T> *p_node;
   shared_ptr<T> *t_node;
//--- sort
   i=beg;
   j=end;
   while(i<end)
     {
      //--- ">>1" is quick division by 2
      p_node=m_data[(beg+end)>>1];
      while(i<j)
        {
         while(m_data[i].Compare(p_node,mode)<0)
           {
            //--- control the output of the array bounds
            if(i==m_data_total-1)
               break;
            i++;
           }
         while(m_data[j].Compare(p_node,mode)>0)
           {
            //--- control the output of the array bounds
            if(j==0)
               break;
            j--;
           }
         if(i<=j)
           {
            t_node=m_data[i];
            m_data[i++]=m_data[j];
            m_data[j]=t_node;
            //--- control the output of the array bounds
            if(j==0)
               break;
            j--;
           }
        }
      if(beg<j)
         QuickSort(beg,j,mode);
      beg=i;
      j=end;
     }
  }
//+------------------------------------------------------------------+
//| Inserting element in a sorted array                              |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::InsertSort(T *element)
  {
   int pos;
//--- check
   if(!CheckPointer(element) || m_sort_mode==-1)
      return(false);
//--- check/reserve elements of array
   if(!Reserve(1))
      return(false);
//--- if the array is empty, add an element
   if(m_data_total==0)
     {
      m_data[m_data_total++]=new shared_ptr<T>(element);
      return(true);
     }
//--- find position and insert
   int mode=m_sort_mode;
   pos=QuickSearch(element);
   if(m_data[pos].Compare(element,m_sort_mode)>0)
      Insert(element,pos);
   else
      Insert(element,pos+1);
//--- restore the sorting flag after Insert(...)
   m_sort_mode=mode;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Quick search of position of element in a sorted array            |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::QuickSearch(const T *element) const
  {
   int      i,j,m=-1;
   shared_ptr<T> *t_node;
//--- search
   i=0;
   j=m_data_total-1;
   while(j>=i)
     {
      //--- ">>1" is quick division by 2
      m=(j+i)>>1;
      if(m<0 || m==m_data_total-1)
         break;
      t_node=m_data[m];
      if(t_node.Compare(element,m_sort_mode)==0)
         break;
      if(t_node.Compare(element,m_sort_mode)>0)
         j=m-1;
      else
         i=m+1;
     }
//--- position
   return(m);
  }
//+------------------------------------------------------------------+
//| Search of position of element in a sorted array                  |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::Search(const T *element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !CheckPointer(element) || m_sort_mode==-1)
      return(-1);
//--- search
   pos=QuickSearch(element);
   if(m_data[pos].Compare(element,m_sort_mode)==0)
      return(pos);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is greater than       |
//| specified in a sorted array                                      |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::SearchGreat(const T *element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !CheckPointer(element) || m_sort_mode==-1)
      return(-1);
//--- search
   pos=QuickSearch(element);
   while(m_data[pos].Compare(element,m_sort_mode)<=0)
      if(++pos==m_data_total)
         return(-1);
//--- position
   return(pos);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is less than          |
//| specified in the sorted array                                    |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::SearchLess(const T *element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !CheckPointer(element) || m_sort_mode==-1)
      return(-1);
//--- search
   pos=QuickSearch(element);
   while(m_data[pos].Compare(element,m_sort_mode)>=0)
      if(pos--==0)
         return(-1);
//--- position
   return(pos);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is greater than or    |
//| equal to the specified in a sorted array                         |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::SearchGreatOrEqual(const T *element) const
  {
//--- check
   if(m_data_total==0 || !CheckPointer(element) || m_sort_mode==-1)
      return(-1);
//--- search
   for(int pos=QuickSearch(element);pos<m_data_total;pos++)
      if(m_data[pos].Compare(element,m_sort_mode)>=0)
         return(pos);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Search position of the first element which is less than or equal |
//| to the specified in a sorted array                               |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::SearchLessOrEqual(const T *element) const
  {
//--- check
   if(m_data_total==0 || !CheckPointer(element) || m_sort_mode==-1)
      return(-1);
//--- search
   for(int pos=QuickSearch(element);pos>=0;pos--)
      if(m_data[pos].Compare(element,m_sort_mode)<=0)
         return(pos);
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Find position of first appearance of element in a sorted array   |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::SearchFirst(const T *element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !CheckPointer(element) || m_sort_mode==-1)
      return(-1);
//--- search
   pos=QuickSearch(element);
   if(m_data[pos].Compare(element,m_sort_mode)==0)
     {
      while(m_data[pos].Compare(element,m_sort_mode)==0)
         if(pos--==0)
            break;
      return(pos+1);
     }
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Find position of last appearance of element in a sorted array    |
//+------------------------------------------------------------------+
template<typename T>
int CArrayObject::SearchLast(const T *element) const
  {
   int pos;
//--- check
   if(m_data_total==0 || !CheckPointer(element) || m_sort_mode==-1)
      return(-1);
//--- search
   pos=QuickSearch(element);
   if(m_data[pos].Compare(element,m_sort_mode)==0)
     {
      while(m_data[pos].Compare(element,m_sort_mode)==0)
         if(++pos==m_data_total)
            break;
      return(pos-1);
     }
//--- not found
   return(-1);
  }
//+------------------------------------------------------------------+
//| Writing array to file                                            |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Save(const int file_handle)
  {
   int i=0;
//--- check
   if(!CAppObjectArray::Save(file_handle))
      return(false);
//--- write array length
   if(FileWriteInteger(file_handle,m_data_total,INT_VALUE)!=INT_VALUE)
      return(false);
//--- write array
   for(i=0;i<m_data_total;i++) {
      if (isset(m_data[i]) && m_data[i].isset()) {
         if (FileWriteInteger(file_handle,m_data[i].Type(),INT_VALUE)!=INT_VALUE)
            return false;
         if(m_data[i].Save(file_handle)!=true)
            break;
      } else {
         if (FileWriteInteger(file_handle,-1,INT_VALUE)!=INT_VALUE)
            return false;
      }
   }
//--- result
   return(i==m_data_total);
  }
//+------------------------------------------------------------------+
//| Reading array from file                                          |
//+------------------------------------------------------------------+
template<typename T>
bool CArrayObject::Load(const int file_handle)
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
         if (type == -1) {
            m_data[i] = new shared_ptr<T>(NULL);
         } else {
            if(!CreateElement(i)) {
               if (!CreateElement(i,type)) {
                  Print("failed to create element of object type ",EnumToString(type),"using object type ",isset(newelement)?EnumToString((ENUM_CLASS_NAMES)newelement.Type()):"NULL");
                  break;
               }
            }
            if(m_data[i].Load(file_handle)!=true) {
               Print("failed to load object type ",EnumToString(type));
               break;
            }
         }
         m_data_total++;
        }
     }
   m_sort_mode=-1;
//--- result
   return(m_data_total==num);
  }
//+------------------------------------------------------------------+

template<typename T>
bool  CArrayObject::CreateElement(const int index, const ENUM_CLASS_NAMES type)
{
   if (!isset(newelement)) return false;
   if (newelement.Type() != classAppObjectArrayObj) {
      if (newelement.Type() == type) {
         T *elem;
         newelement.callback(0,elem);
         m_data[index] = new shared_ptr<T>(elem);
         Prepare(m_data[index].get());
         return true;
      }
   } else {
      CArrayObject* list = newelement;
      for (int i = 0; i < list.Total(); i++) {
         CAppObject* thiselement = list.At(i);
         if (thiselement.Type() == type) {
            T *elem1;
            thiselement.callback(0,elem1);
            m_data[index] = new shared_ptr<T>(elem1);
            Prepare(m_data[index].get());
            return true;
         }
      }  
   }
   return(false);
}

CArrayObject<CAppObject> ___arrayobj;
  
