class CError : public CEventLog
{
public:
  int const Type() { return classEventLog; }
  CError(const string _message, const string _function = "")
  {
     type = E_ERROR;
     message = _message;
     function = _function;
  }
};