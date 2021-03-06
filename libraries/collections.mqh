#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Arrays\ArrayInt.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\Tree.mqh>


template<typename T>
class CIteratorObj : public CObject {
public:
   virtual T* GetNext() {
      return NULL;
   }
   virtual bool HasNext() {
      return false;
   }
};

template<typename T>
class CIteratorPrimitive : public CObject {
public:
   virtual T GetNext() {
      return NULL;
   }
   virtual bool HasNext() {
      return false;
   }
};

template<typename T>
class CIterableObj : public CObject {
public:
   virtual CIteratorObj<T>* GetIterator() {
      return NULL;
   }
};

template<typename T>
class CIterablePrimitive : public CObject {
public:
   virtual CIteratorPrimitive<T>* GetIterator() {
      return NULL;
   }
};

template<typename T>
class CIterableObjByIdx : public CIterableObj<T> {
public:
   virtual CIteratorObj<T>* GetIterator() {
      return NULL;
   }
   virtual int Total() {
      return -1;
   }
   virtual T* At(int idx) {
      return NULL;
   }
   virtual bool HasNext(int idx) {
      return idx < this.Total();
   }
   virtual T* GetNext(int& idx) {
      T* next = At(idx);
      idx++;
      return next;
   }
};

template<typename T>
class CIterablePrimitiveByIdx : public CIterablePrimitive<T> {
public:
   virtual CIteratorPrimitive<T>* GetIterator() {
      return NULL;
   }
   virtual int Total() {
      return -1;
   }
   virtual T At(int idx) {
      return NULL;
   }
   virtual bool HasNext(int idx) {
      return idx < this.Total();
   }
   virtual T GetNext(int& idx) {
      T next = At(idx);
      idx++;
      return next;
   }
};

template<typename T>
class CIteratorObjByIdx : public CIteratorObj<T> {
private:
   int m_idx;
   CIterableObjByIdx<T>* m_subject;
public:
   CIteratorObjByIdx(CIterableObjByIdx<T>* subject): m_subject(subject), m_idx(0) {}
   virtual bool HasNext() {
      return m_idx < m_subject.Total();
   }
   virtual T* GetNext() {
      T* next = m_subject.At(m_idx);
      m_idx++;
      return next;
   }
};

template<typename T>
class CIteratorPrimitiveByIdx : public CIteratorPrimitive<T> {
private:
   int m_idx;
   CIterablePrimitiveByIdx<T>* m_subject;
public:
   CIteratorPrimitiveByIdx(CIterablePrimitiveByIdx<T>* subject): m_subject(subject), m_idx(0) {}
   virtual bool HasNext() {
      return m_idx < m_subject.Total();
   }
   virtual T GetNext() {
      T next = m_subject.At(m_idx);
      m_idx++;
      return next;
   }
};


class CSetInt : public CObject {
private:
   CArrayInt m_arr;
public:
   CSetInt() {
      m_arr.Sort();
   }
   void Add(int num) {
      m_arr.InsertSort(num);
   }
   bool Remove(int num) {
      int pos = m_arr.Search(num);
      if (pos == -1) return false;
      m_arr.Delete(pos);
      return true;
   }
   bool Contains(int num) {
      return m_arr.Search(num) != -1;
   }
};

class CInt : public CObject {
private:
   int m_val;
public:
   CInt(int val): m_val(val) {
   }
   int GetValue() {
      return m_val;
   }
   virtual int Type(void) const { return(1573847047);}
   virtual int Compare(const CObject* node, const int mode = 0) const {
      if (node.Type() == this.Type()) {
         CInt* other = (CInt*)node;
         if (this.m_val == other.m_val) return 0;
         else if (this.m_val < other.m_val) return -1;
         else return 1;
      } else {
         return EMPTY_VALUE;
      }
   }
   virtual string ToString() {
      return (string)m_val;
   }
};

template<typename T>
class CPrimitive : public CObject {
private:
   T m_val;
public:
   CPrimitive(T val): m_val(val) {}
   T GetValue() {
      return m_val;
   }
   virtual int Type(void) const { return(1);}
   virtual int Compare(const CObject* node, const int mode = 0) const {
      if (node.Type() == this.Type()) {
         CInt* other = (CInt*)node;
         if (this.m_val == other.m_val) return 0;
         else if (this.m_val < other.m_val) return -1;
         else return 1;
      } else {
         return EMPTY_VALUE;
      }
   }
   virtual string ToString() {
      return (string)m_val;
   }
};


template<typename T>
class CSetItem : public CTreeNode {
private:
   T* m_content;
   bool m_free_mode;
public:
   CSetItem(T* content): m_content(content), m_free_mode(false) {}
   CSetItem(T* content, bool free_mode): m_content(content), m_free_mode(free_mode) {}
   T* GetContent() {
      return m_content;
   }
   virtual int Compare(const CObject *node,const int mode=0) const {
      return m_content.Compare(((CSetItem*)node).m_content,mode);
   }
};

template<typename T>
class CSetObj : public CObject {
private:
   CTree m_arr;
   bool m_free_mode;
public:
   CSetObj(): m_free_mode(true) {}
   CSetObj(bool free_mode): m_free_mode(free_mode) {}
   void Add(T* val) {
      CSetItem<T> findItem(val);
      if (m_arr.Find(GetPointer(findItem))) m_arr.Delete(GetPointer(findItem));
      m_arr.Insert(new CSetItem<T>(val,m_free_mode));
   }
   bool Remove(T* val) {
      CSetItem<T> findItem(val);
      return m_arr.Delete(GetPointer(findItem));
   }
   T* Find(T* val) {
      CSetItem<T> findItem(val);
      CSetItem<T>* found = (CSetItem<T>*)m_arr.Find(GetPointer(findItem));
      return found!=NULL?found.GetContent():NULL;
   }
   bool Contains(T* val) {
      CSetItem<T> findItem(val);
      CSetItem<T>* found = (CSetItem<T>*)m_arr.Find(GetPointer(findItem));
      return found != NULL;
   }
};

class CSetObj_CObject : public CSetObj<CObject> {};

template<typename T>
class CSetItemPrimitive : public CTreeNode {
private:
   T m_content;
public:
   CSetItemPrimitive(T content): m_content(content) {}
   T GetContent() {
      return m_content;
   }
   virtual int Compare(const CObject* node, const int mode = 0) const {
      CSetItemPrimitive* other = (CSetItemPrimitive*)node;
      if (this.m_content == other.m_content) return 0;
      else if (this.m_content < other.m_content) return -1;
      else return 1;
   }
};

template<typename T>
class CSetPrimitive : public CObject {
private:
   CTree m_arr;
public:
   void Add(T val) {
      CSetItemPrimitive<T> findItem(val);
      if (m_arr.Find(GetPointer(findItem))) m_arr.Delete(GetPointer(findItem));
      m_arr.Insert(new CSetItemPrimitive<T>(val));
   }
   bool Remove(T val) {
      CSetItemPrimitive<T> findItem(val);
      return m_arr.Delete(GetPointer(findItem));
   }
   T Find(T val) {
      CSetItemPrimitive<T> findItem(val);
      CSetItemPrimitive<T>* found = (CSetItemPrimitive<T>*)m_arr.Find(GetPointer(findItem));
      return found!=NULL?found.GetContent():NULL;
   }
   bool Contains(T val) {
      CSetItemPrimitive<T> findItem(val);
      CSetItemPrimitive<T>* found = (CSetItemPrimitive<T>*)m_arr.Find(GetPointer(findItem));
      return found != NULL;
   }
   void operator+=(const T toAdd) {
      this.Add(toAdd);
   }
};

template<typename K,typename T>
class CEntryPrimitiveObj : public CObject {
private:
   K m_name;
   T* m_val;
public:
   CEntryPrimitiveObj(K name, T* val): m_name(name), m_val(val) {}
   virtual int Type(void) const { return(124);}
   virtual int Compare(const CObject* node, const int mode = 0) const {
      if (node.Type() == this.Type()) {
         CEntryPrimitiveObj<K,T>* other = (CEntryPrimitiveObj<K,T>*)node;
         if (this.m_name == other.m_name) return 0;
         else if (this.m_name < other.m_name) return -1;
         else return 1;
      } else {
         return EMPTY_VALUE;
      }
   }
   virtual T* GetValue() {
      return m_val;
   }
};

template<typename K,typename T>
class CEntryPrimitive : public CObject {
private:
   K m_name;
   T m_val;
public:
   CEntryPrimitive() {}
   CEntryPrimitive(K name, T val): m_name(name), m_val(val) {}
   virtual int Type(void) const { return(124);}
   virtual int Compare(const CObject* node, const int mode = 0) const {
      if (node.Type() == this.Type()) {
         CEntryPrimitive<K,T>* other = (CEntryPrimitive<K,T>*)node;
         if (this.m_name == other.m_name) return 0;
         else if (this.m_name < other.m_name) return -1;
         else return 1;
      } else {
         return EMPTY_VALUE;
      }
   }
   virtual T GetValue() {
      return m_val;
   }
   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      string k = typename(K);
      if (k == "int") {
         if (!file.WriteInteger(m_name)) return file.Error("m_name",__FUNCTION__);
      }
      
      string t = typename(T);
      if (t == "int") {
         if (!file.WriteInteger(m_val)) return file.Error("m_val",__FUNCTION__);
      }

      return(true);  
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;
      
      string k = typename(K);
      if (k == "int") {
         if (!file.ReadInteger(m_name)) return file.Error("m_name",__FUNCTION__);
      }
      
      string t = typename(T);
      if (t == "int") {
         if (!file.ReadInteger(m_val)) return file.Error("m_val",__FUNCTION__);
      }
            
      return(true);  
   }
};

template<typename T>
class CEntryStrObj : public CObject {
private:
   string m_name;
   T* m_val;
public:
   CEntryStrObj(string name, T* val): m_name(name), m_val(val) {}
   virtual int Type(void) const { return(123);}
   virtual int Compare(const CObject* node, const int mode = 0) const {
      if (node.Type() == this.Type()) {
         CEntryStrObj<T>* other = (CEntryStrObj<T>*)node;
         if (this.m_name == other.m_name) return 0;
         else if (this.m_name < other.m_name) return -1;
         else return 1;
      } else {
         return EMPTY_VALUE;
      }
   }
   virtual T* GetValue() {
      return m_val;
   }
};

template<typename K,typename T>
class CMapPrimitiveObj : public CIterableObjByIdx<T> {
private:
    CArrayObj m_arr;
public:
   CMapPrimitiveObj() {
      m_arr.Sort();
   }
   virtual int Type(void) const { return(1573847623);}
   void Put(K key, CObject* val) {
      CEntryPrimitiveObj<K,T>* newEntry = new CEntryPrimitiveObj<K,T>(key,val);
      int pos = m_arr.Search(newEntry);
      if (pos != -1) {
         m_arr.Delete(pos);
      }
      m_arr.InsertSort(newEntry);
   }
   void Remove(K key) {
      CEntryPrimitiveObj<K,T> findBy(key,NULL);
      int pos = m_arr.Search(GetPointer(findBy));
      if (pos != -1) {
         m_arr.Delete(pos);
      }
   }
   bool IsKeyPresent(K key) {
      CEntryPrimitiveObj<K,T> findBy(key,NULL);
      int idx = m_arr.Search(GetPointer(findBy));
      return idx != -1;
   }
   T* Get(K key) {
      CEntryPrimitiveObj<K,T> findBy(key,NULL);
      int idx = m_arr.Search(GetPointer(findBy));
      if (idx == -1) return NULL;
      else {
         CEntryPrimitiveObj<K,T>* entry = m_arr.At(idx);
         return entry.GetValue();
      }
   }
   virtual int Total() {
      return m_arr.Total();
   }
   virtual T* At(int idx) {
       CEntryPrimitiveObj<K,T>* entry = m_arr.At(idx);
       return entry.GetValue();
   }
   virtual CIteratorObj<T>* GetIterator() {
      return new CIteratorObjByIdx<T>(GetPointer(this));
   }
   T* operator[](K key) {
      return this.Get(key);
   }
};

template<typename T>
class CArrayObjTyped : public CArrayObj {
   virtual bool CreateElement(const int index) {
      m_data[index] = new T();
      return true;
   }
};

template<typename K,typename T>
class CMapPrimitive : public CIterablePrimitiveByIdx<T> {
private:
    CArrayObjTyped<CEntryPrimitive<K,T>> m_arr;
public:
   CMapPrimitive() {
      m_arr.Sort();
   }
   virtual int Type(void) const { return(1573847623);}
   void Put(K key, T val) {
      CEntryPrimitive<K,T>* newEntry = new CEntryPrimitive<K,T>(key,val);
      int pos = m_arr.Search(newEntry);
      if (pos != -1) {
         m_arr.Delete(pos);
      }
      m_arr.InsertSort(newEntry);
   }
   void Remove(K key) {
      CEntryPrimitive<K,T> findBy(key,NULL);
      int pos = m_arr.Search(GetPointer(findBy));
      if (pos != -1) {
         m_arr.Delete(pos);
      }
   }
   bool IsKeyPresent(K key) {
      CEntryPrimitive<K,T> findBy(key,NULL);
      int idx = m_arr.Search(GetPointer(findBy));
      return idx != -1;
   }
   T Get(K key) {
      CEntryPrimitive<K,T> findBy(key,NULL);
      int idx = m_arr.Search(GetPointer(findBy));
      if (idx == -1) return NULL;
      else {
         CEntryPrimitive<K,T>* entry = m_arr.At(idx);
         return entry.GetValue();
      }
   }
   virtual int Total() {
      return m_arr.Total();
   }
   virtual T At(int idx) {
       CEntryPrimitive<K,T>* entry = m_arr.At(idx);
       return entry.GetValue();
   }
   virtual CIteratorPrimitive<T>* GetIterator() {
      return new CIteratorPrimitiveByIdx<T>(GetPointer(this));
   }
   T operator[](K key) {
      return this.Get(key);
   }
   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;

      if (!file.WriteObject(GetPointer(m_arr))) return file.Error("m_arr",__FUNCTION__);

      return(true);  
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;
      
      if (!file.ReadObject(GetPointer(m_arr))) return file.Error("m_arr",__FUNCTION__);
      m_arr.Sort();
      
      return(true);  
   }
};


template<typename T>
class CMapStrObj : public CIterableObjByIdx<T> {
private:
    CArrayObj m_arr;
public:
   CMapStrObj() {
      m_arr.Sort();
   }
   virtual int Type(void) const { return(1573847622);}
   void Put(string key, CObject* val) {
      CEntryStrObj<T>* newEntry = new CEntryStrObj<T>(key,val);
      int pos = m_arr.Search(newEntry);
      if (pos != -1) {
         m_arr.Delete(pos);
      }
      m_arr.InsertSort(newEntry);
   }
   void Remove(string key) {
      CEntryStrObj<T> findBy(key,NULL);
      int pos = m_arr.Search(GetPointer(findBy));
      if (pos != -1) {
         m_arr.Delete(pos);
      }
   }
   bool IsKeyPresent(string key) {
      CEntryStrObj<T> findBy(key,NULL);
      int idx = m_arr.Search(GetPointer(findBy));
      return idx != -1;
   }
   T* Get(string key) {
      CEntryStrObj<T> findBy(key,NULL);
      int idx = m_arr.Search(GetPointer(findBy));
      if (idx == -1) return NULL;
      else {
         CEntryStrObj<T>* entry = m_arr.At(idx);
         return entry.GetValue();
      }
   }
   virtual int Total() {
      return m_arr.Total();
   }
   virtual T* At(int idx) {
       CEntryStrObj<T>* entry = m_arr.At(idx);
       return entry.GetValue();
   }
   virtual CIteratorObj<T>* GetIterator() {
      return new CIteratorObjByIdx<T>(GetPointer(this));
   }
   T* operator[](string key) {
      return this.Get(key);
   }
};


