//+------------------------------------------------------------------+
//|                                                         file.mqh |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
/**File**/
#include <Object.mqh>

class MTPFile : public CObject
  {
protected:
   int               m_handle;             // handle of file
   string            m_name;               // name of opened file
   int               m_flags;              // flags of opened file

public:
                     MTPFile(void);
                    ~MTPFile(void);
   //--- methods of access to protected data
   int               Handle(void)              const { return(m_handle); };
   string            FileName(void)            const { return(m_name);   };
   int               Flags(void)               const { return(m_flags);  };
   void              SetUnicode(const bool unicode);
   void              SetCommon(const bool common);
   //--- general methods for working with files
   int               Open(const string file_name,int open_flags,const short delimiter='\t');
   void              Close(void);
   void              Delete(void);
   ulong             Size(void);
   ulong             Tell(void);
   void              Seek(const long offset,const ENUM_FILE_POSITION origin);
   void              Flush(void);
   bool              IsEnding(void);
   bool              IsLineEnding(void);
   //--- general methods for working with files
   void              Delete(const string file_name);
   bool              IsExist(const string file_name);
   bool              Copy(const string src_name,const int common_flag,const string dst_name,const int mode_flags);
   bool              Move(const string src_name,const int common_flag,const string dst_name,const int mode_flags);
   //--- general methods of working with folders
   bool              FolderCreate(const string folder_name);
   bool              FolderDelete(const string folder_name);
   bool              FolderClean(const string folder_name);
   //--- general methods of finding files
   long              FileFindFirst(const string file_filter,string &returned_filename);
   bool              FileFindNext(const long search_handle,string &returned_filename);
   void              FileFindClose(const long search_handle);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
MTPFile::MTPFile(void) : m_handle(INVALID_HANDLE),
                     m_name(""),
                     m_flags(FILE_ANSI)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
MTPFile::~MTPFile(void)
  {
//--- check handle
   //if(m_handle!=INVALID_HANDLE)
      //Close();
  }
//+------------------------------------------------------------------+
//| Set the FILE_UNICODE flag                                        |
//+------------------------------------------------------------------+
void MTPFile::SetUnicode(const bool unicode)
  {
//--- check handle
   if(m_handle==INVALID_HANDLE)
     {
      if(unicode)
         m_flags|=FILE_UNICODE;
      else
         m_flags^=FILE_UNICODE;
     }
  }
//+------------------------------------------------------------------+
//| Set the "Common Folder" flag                                     |
//+------------------------------------------------------------------+
void MTPFile::SetCommon(const bool common)
  {
//--- check handle
   if(m_handle==INVALID_HANDLE)
     {
      if(common)
         m_flags|=FILE_COMMON;
      else
         m_flags^=FILE_COMMON;
     }
  }
//+------------------------------------------------------------------+
//| Open the file                                                    |
//+------------------------------------------------------------------+
int MTPFile::Open(const string file_name,int open_flags,const short delimiter)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      Close();
//--- action
   if((open_flags &(FILE_BIN|FILE_CSV))==0)
      open_flags|=FILE_TXT;
//--- open
   m_handle=FileOpen(file_name,open_flags|m_flags,delimiter);
   if(m_handle!=INVALID_HANDLE)
     {
      //--- store options of the opened file
      m_flags|=open_flags;
      m_name=file_name;
     }
//--- result
   return(m_handle);
  }
//+------------------------------------------------------------------+
//| Close the file                                                   |
//+------------------------------------------------------------------+
void MTPFile::Close(void)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      //--- closing the file and resetting all the variables to the initial state
      FileClose(m_handle);
      m_handle=INVALID_HANDLE;
      m_name="";
      //--- reset all flags except the text
      m_flags&=FILE_ANSI|FILE_UNICODE;
     }
  }
//+------------------------------------------------------------------+
//| Deleting an open file                                            |
//+------------------------------------------------------------------+
void MTPFile::Delete(void)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      string file_name=m_name;
      Close();
      //--- delete
      FileDelete(file_name,m_flags);
     }
  }
//+------------------------------------------------------------------+
//| Get size of opened file                                          |
//+------------------------------------------------------------------+
ulong MTPFile::Size(void)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileSize(m_handle));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Get current position of pointer in file                          |
//+------------------------------------------------------------------+
ulong MTPFile::Tell(void)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileTell(m_handle));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Set position of pointer in file                                  |
//+------------------------------------------------------------------+
void MTPFile::Seek(const long offset,const ENUM_FILE_POSITION origin)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      FileSeek(m_handle,offset,origin);
  }
//+------------------------------------------------------------------+
//| Flush data from the file buffer of input-output to disk          |
//+------------------------------------------------------------------+
void MTPFile::Flush(void)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      FileFlush(m_handle);
  }
//+------------------------------------------------------------------+
//| Detect the end of file                                           |
//+------------------------------------------------------------------+
bool MTPFile::IsEnding(void)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileIsEnding(m_handle));
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Detect the end of string                                         |
//+------------------------------------------------------------------+
bool MTPFile::IsLineEnding(void)
  {
//--- checking
   if(m_handle!=INVALID_HANDLE)
      if((m_flags&FILE_BIN)==0)
         return(FileIsLineEnding(m_handle));
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Deleting a file                                                  |
//+------------------------------------------------------------------+
void MTPFile::Delete(const string file_name)
  {
//--- checking
   if(file_name==m_name)
      Close();
//--- delete
   FileDelete(file_name,m_flags);
  }
//+------------------------------------------------------------------+
//| Check if file exists                                             |
//+------------------------------------------------------------------+
bool MTPFile::IsExist(const string file_name)
  {
   return(FileIsExist(file_name,m_flags));
  }
//+------------------------------------------------------------------+
//| Copying file                                                     |
//+------------------------------------------------------------------+
bool MTPFile::Copy(const string src_name,const int common_flag,const string dst_name,const int mode_flags)
  {
   return(FileCopy(src_name,common_flag,dst_name,mode_flags));
  }
//+------------------------------------------------------------------+
//| Move/rename file                                                 |
//+------------------------------------------------------------------+
bool MTPFile::Move(const string src_name,const int common_flag,const string dst_name,const int mode_flags)
  {
   return(FileMove(src_name,common_flag,dst_name,mode_flags));
  }
//+------------------------------------------------------------------+
//| Create folder                                                    |
//+------------------------------------------------------------------+
bool MTPFile::FolderCreate(const string folder_name)
  {
   return(::FolderCreate(folder_name,m_flags));
  }
//+------------------------------------------------------------------+
//| Delete folder                                                    |
//+------------------------------------------------------------------+
bool MTPFile::FolderDelete(const string folder_name)
  {
   return(::FolderDelete(folder_name,m_flags));
  }
//+------------------------------------------------------------------+
//| Clean folder                                                     |
//+------------------------------------------------------------------+
bool MTPFile::FolderClean(const string folder_name)
  {
   return(::FolderClean(folder_name,m_flags));
  }
//+------------------------------------------------------------------+
//| Start search of files                                            |
//+------------------------------------------------------------------+
long MTPFile::FileFindFirst(const string file_filter,string &returned_filename)
  {
   return(::FileFindFirst(file_filter,returned_filename,m_flags));
  }
//+------------------------------------------------------------------+
//| Continue search of files                                         |
//+------------------------------------------------------------------+
bool MTPFile::FileFindNext(const long search_handle,string &returned_filename)
  {
   return(::FileFindNext(search_handle,returned_filename));
  }
//+------------------------------------------------------------------+
//| End search of files                                              |
//+------------------------------------------------------------------+
void MTPFile::FileFindClose(const long search_handle)
  {
   ::FileFindClose(search_handle);
  }
//+------------------------------------------------------------------+

/**FileBase**/

class MTPFileBinBase : public MTPFile
  {
public:
   static bool       Error(string field, string function) { Print("Save/Load Error: "+function+"::"+field); return(false); }
                     MTPFileBinBase(void);
                    ~MTPFileBinBase(void);
   //--- methods for working with files
   int               Open(const string file_name,const int open_flags);
   //--- methods for writing data
   uint              WriteChar(const char value);
   uint              WriteShort(const short value);
   uint              WriteInteger(const int value);
   uint              WriteLong(const long value);
   uint              WriteFloat(const float value);
   uint              WriteDouble(const double value);
   int               WriteString(const string value);
   int               WriteString(const string value,const int size);
   uint              WriteCharArray(const char &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              WriteShortArray(const short& array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              WriteIntegerArray(const int& array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              WriteLongArray(const long &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              WriteFloatArray(const float &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              WriteDoubleArray(const double &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   template<typename T>
   uint              WriteArray(T &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   template<typename T>
   uint              WriteStruct(T &data);
   bool              WriteObject(CObject *object);
   //--- methods for reading data
   bool              ReadChar(char &value);
   bool              ReadShort(short &value);
   bool              ReadInteger(int &value);
   bool              ReadLong(long &value);
   bool              ReadFloat(float &value);
   bool              ReadDouble(double &value);
   bool              ReadString(string &value);
   bool              ReadString(string &value,const int size);
   uint              ReadCharArray(char &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              ReadShortArray(short& array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              ReadIntegerArray(int& array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              ReadLongArray(long &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              ReadFloatArray(float &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   uint              ReadDoubleArray(double &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   template<typename T>
   uint              ReadArray(T &array[],const int start_item=0,const int items_count=WHOLE_ARRAY);
   template<typename T>
   uint              ReadStruct(T &data);
   bool              ReadObject(CObject *object);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
MTPFileBinBase::MTPFileBinBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
MTPFileBinBase::~MTPFileBinBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Opening a binary file                                            |
//+------------------------------------------------------------------+
int MTPFileBinBase::Open(const string file_name,const int open_flags)
  {
   return(MTPFile::Open(file_name,open_flags|FILE_BIN));
  }
//+------------------------------------------------------------------+
//| Write a variable of char or uchar type                           |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteChar(const char value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteInteger(m_handle,value,sizeof(char)));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of short or ushort type                         |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteShort(const short value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteInteger(m_handle,value,sizeof(short)));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of int or uint type                             |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteInteger(const int value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteInteger(m_handle,value,sizeof(int)));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of long or ulong type                           |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteLong(const long value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteLong(m_handle,value));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of float type                                   |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteFloat(const float value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteFloat(m_handle,value));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of double type                                  |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteDouble(const double value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteDouble(m_handle,value));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write a variable of string type                                  |
//+------------------------------------------------------------------+
int MTPFileBinBase::WriteString(const string value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      //--- size of string
      int size=StringLen(value);
      //--- write
      if(FileWriteInteger(m_handle,size)==sizeof(int))
         return(FileWriteString(m_handle,value,size));
     }
//--- failure
   return(-1);
  }
//+------------------------------------------------------------------+
//| Write a part of string                                           |
//+------------------------------------------------------------------+
int MTPFileBinBase::WriteString(const string value,const int size)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteString(m_handle,value,size));
//--- failure
   return(-1);
  }
//+------------------------------------------------------------------+
//| Write array variables of type char or uchar                      |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteCharArray(const char &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of short or ushort type              |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteShortArray(const short &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of int or uint type                  |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteIntegerArray(const int &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of long or ulong type                |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteLongArray(const long &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of float type                        |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteFloatArray(const float &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of double type                       |
//+------------------------------------------------------------------+
uint MTPFileBinBase::WriteDoubleArray(const double &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an array of variables of any type                          |
//+------------------------------------------------------------------+
template<typename T>
uint MTPFileBinBase::WriteArray(T &array[],const int start_item=0,const int items_count=WHOLE_ARRAY)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write an structure                                               |
//+------------------------------------------------------------------+
template<typename T>
uint MTPFileBinBase::WriteStruct(T &data)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteStruct(m_handle,data));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Write data of an instance of the CObject class                   |
//+------------------------------------------------------------------+
bool MTPFileBinBase::WriteObject(CObject *object)
  {
//--- check handle & object
   if(m_handle!=INVALID_HANDLE)
      if(CheckPointer(object))
         return(object.Save(m_handle));
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of char or uchar type                            |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadChar(char &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=(char)FileReadInteger(m_handle,sizeof(char));
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of short or ushort type                          |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadShort(short &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=(short)FileReadInteger(m_handle,sizeof(short));
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of int or uint type                              |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadInteger(int &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadInteger(m_handle,sizeof(int));
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of long or ulong type                            |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadLong(long &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadLong(m_handle);
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of float type                                    |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadFloat(float &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadFloat(m_handle);
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of double type                                   |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadDouble(double &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadDouble(m_handle);
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a variable of string type                                   |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadString(string &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      int size=FileReadInteger(m_handle);
      if(GetLastError()==0)
        {
         value=FileReadString(m_handle,size);
         return(size==StringLen(value));
        }
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read a part of string                                            |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadString(string &value,const int size)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      value=FileReadString(m_handle,size);
      return(size==StringLen(value));
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of char or uchar type                 |
//+------------------------------------------------------------------+
uint MTPFileBinBase::ReadCharArray(char &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileReadArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of short or ushort type               |
//+------------------------------------------------------------------+
uint MTPFileBinBase::ReadShortArray(short &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileReadArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of int or uint type                   |
//+------------------------------------------------------------------+
uint MTPFileBinBase::ReadIntegerArray(int &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileReadArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of long or ulong type                 |
//+------------------------------------------------------------------+
uint MTPFileBinBase::ReadLongArray(long &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileReadArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of float type                         |
//+------------------------------------------------------------------+
uint MTPFileBinBase::ReadFloatArray(float &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileReadArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of double type                        |
//+------------------------------------------------------------------+
uint MTPFileBinBase::ReadDoubleArray(double &array[],const int start_item,const int items_count)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileReadArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Read an array of variables of any type                           |
//+------------------------------------------------------------------+
template<typename T>
uint MTPFileBinBase::ReadArray(T &array[],const int start_item=0,const int items_count=WHOLE_ARRAY)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileReadArray(m_handle,array,start_item,items_count));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Read an structure                                                |
//+------------------------------------------------------------------+
template<typename T>
uint MTPFileBinBase::ReadStruct(T &data)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileReadStruct(m_handle,data));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//| Read data of an instance of the CObject class                    |
//+------------------------------------------------------------------+
bool MTPFileBinBase::ReadObject(CObject *object)
  {
//--- check handle & object
   if(m_handle!=INVALID_HANDLE)
      if(CheckPointer(object))
         return(object.Load(m_handle));
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+


/**FileBin**/

class MTPFileBin : public MTPFileBinBase
  {
private:

public:
                     MTPFileBin();
                    ~MTPFileBin();
   void              Handle(const int handle) {m_handle=handle;}
   bool              Invalid() {return(m_handle==INVALID_HANDLE);}
   bool              ReadBool(bool &value);
   uint              WriteBool(bool value);
   bool              ReadDateTime(datetime &value);
   uint              WriteDateTime(datetime value);
   bool              ReadColor(color &value);
   uint              WriteColor(color value);  
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MTPFileBin::MTPFileBin()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MTPFileBin::~MTPFileBin()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MTPFileBin::ReadBool(bool &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value= (bool) FileReadInteger(m_handle,sizeof(int));
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint MTPFileBin::WriteBool(bool value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteInteger(m_handle,value,sizeof(int)));
//--- failure
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MTPFileBin::ReadDateTime(datetime &value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      value=FileReadInteger(m_handle,sizeof(int));
      return(GetLastError()==0);
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint MTPFileBin::WriteDateTime(datetime value)
  {
//--- check handle
   if(m_handle!=INVALID_HANDLE)
      return(FileWriteInteger(m_handle,value,sizeof(int)));
//--- failure
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MTPFileBin::ReadColor(color &value)
  {
//--- check handle
   string str;
   if(m_handle!=INVALID_HANDLE)
     {
      ResetLastError();
      int size=FileReadInteger(m_handle);
      if(GetLastError()==0)
        {
         str = FileReadString(m_handle,size);
         value=StringToColor(str);
         return(size==StringLen(str));
        }
     }
//--- failure
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint MTPFileBin::WriteColor(color value)
  {
//--- check handle
   string str = ColorToString(value);
   if(m_handle!=INVALID_HANDLE)
     {
      //--- size of string
      int size=StringLen(str);
      //--- write
      if(FileWriteInteger(m_handle,size)==sizeof(int))
         return(FileWriteString(m_handle,str,size));
     }
//--- failure
   return(0);
  }

