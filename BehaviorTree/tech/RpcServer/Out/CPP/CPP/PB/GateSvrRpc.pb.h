// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: GateSvrRpc.proto

#ifndef PROTOBUF_GateSvrRpc_2eproto__INCLUDED
#define PROTOBUF_GateSvrRpc_2eproto__INCLUDED

#include <string>

#include <google/protobuf/stubs/common.h>

#if GOOGLE_PROTOBUF_VERSION < 2005000
#error This file was generated by a newer version of protoc which is
#error incompatible with your Protocol Buffer headers.  Please update
#error your headers.
#endif
#if 2005000 < GOOGLE_PROTOBUF_MIN_PROTOC_VERSION
#error This file was generated by an older version of protoc which is
#error incompatible with your Protocol Buffer headers.  Please
#error regenerate this file with a newer version of protoc.
#endif

#include <google/protobuf/generated_message_util.h>
#include <google/protobuf/message.h>
#include <google/protobuf/repeated_field.h>
#include <google/protobuf/extension_set.h>
#include <google/protobuf/unknown_field_set.h>
#include "PublicStruct.pb.h"
// @@protoc_insertion_point(includes)

// Internal implementation detail -- do not call these.
void  protobuf_AddDesc_GateSvrRpc_2eproto();
void protobuf_AssignDesc_GateSvrRpc_2eproto();
void protobuf_ShutdownFile_GateSvrRpc_2eproto();

class GateRpcSendMsgNotify;
class GateRpcBroadcastMsgNotify;
class GateRpcCloseNodeNotify;
class GateRpcRegisterModuleNotify;
class GateRpcKickNotify;
class GateRpcOnlineNotify;

// ===================================================================

class GateRpcSendMsgNotify : public ::google::protobuf::Message {
 public:
  GateRpcSendMsgNotify();
  virtual ~GateRpcSendMsgNotify();

  GateRpcSendMsgNotify(const GateRpcSendMsgNotify& from);

  inline GateRpcSendMsgNotify& operator=(const GateRpcSendMsgNotify& from) {
    CopyFrom(from);
    return *this;
  }

  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _unknown_fields_;
  }

  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return &_unknown_fields_;
  }

  static const ::google::protobuf::Descriptor* descriptor();
  static const GateRpcSendMsgNotify& default_instance();

  void Swap(GateRpcSendMsgNotify* other);

  // implements Message ----------------------------------------------

  GateRpcSendMsgNotify* New() const;
  void CopyFrom(const ::google::protobuf::Message& from);
  void MergeFrom(const ::google::protobuf::Message& from);
  void CopyFrom(const GateRpcSendMsgNotify& from);
  void MergeFrom(const GateRpcSendMsgNotify& from);
  void Clear();
  bool IsInitialized() const;

  int ByteSize() const;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input);
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const;
  ::google::protobuf::uint8* SerializeWithCachedSizesToArray(::google::protobuf::uint8* output) const;
  int GetCachedSize() const { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const;
  public:

  ::google::protobuf::Metadata GetMetadata() const;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  // repeated sint64 UidArr = 1;
  inline int uidarr_size() const;
  inline void clear_uidarr();
  static const int kUidArrFieldNumber = 1;
  inline ::google::protobuf::int64 uidarr(int index) const;
  inline void set_uidarr(int index, ::google::protobuf::int64 value);
  inline void add_uidarr(::google::protobuf::int64 value);
  inline const ::google::protobuf::RepeatedField< ::google::protobuf::int64 >&
      uidarr() const;
  inline ::google::protobuf::RepeatedField< ::google::protobuf::int64 >*
      mutable_uidarr();

  // optional bytes Msg = 2;
  inline bool has_msg() const;
  inline void clear_msg();
  static const int kMsgFieldNumber = 2;
  inline const ::std::string& msg() const;
  inline void set_msg(const ::std::string& value);
  inline void set_msg(const char* value);
  inline void set_msg(const void* value, size_t size);
  inline ::std::string* mutable_msg();
  inline ::std::string* release_msg();
  inline void set_allocated_msg(::std::string* msg);

  // @@protoc_insertion_point(class_scope:GateRpcSendMsgNotify)
 private:
  inline void set_has_msg();
  inline void clear_has_msg();

  ::google::protobuf::UnknownFieldSet _unknown_fields_;

  ::google::protobuf::RepeatedField< ::google::protobuf::int64 > uidarr_;
  ::std::string* msg_;

  mutable int _cached_size_;
  ::google::protobuf::uint32 _has_bits_[(2 + 31) / 32];

  friend void  protobuf_AddDesc_GateSvrRpc_2eproto();
  friend void protobuf_AssignDesc_GateSvrRpc_2eproto();
  friend void protobuf_ShutdownFile_GateSvrRpc_2eproto();

  void InitAsDefaultInstance();
  static GateRpcSendMsgNotify* default_instance_;
};
// -------------------------------------------------------------------

class GateRpcBroadcastMsgNotify : public ::google::protobuf::Message {
 public:
  GateRpcBroadcastMsgNotify();
  virtual ~GateRpcBroadcastMsgNotify();

  GateRpcBroadcastMsgNotify(const GateRpcBroadcastMsgNotify& from);

  inline GateRpcBroadcastMsgNotify& operator=(const GateRpcBroadcastMsgNotify& from) {
    CopyFrom(from);
    return *this;
  }

  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _unknown_fields_;
  }

  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return &_unknown_fields_;
  }

  static const ::google::protobuf::Descriptor* descriptor();
  static const GateRpcBroadcastMsgNotify& default_instance();

  void Swap(GateRpcBroadcastMsgNotify* other);

  // implements Message ----------------------------------------------

  GateRpcBroadcastMsgNotify* New() const;
  void CopyFrom(const ::google::protobuf::Message& from);
  void MergeFrom(const ::google::protobuf::Message& from);
  void CopyFrom(const GateRpcBroadcastMsgNotify& from);
  void MergeFrom(const GateRpcBroadcastMsgNotify& from);
  void Clear();
  bool IsInitialized() const;

  int ByteSize() const;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input);
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const;
  ::google::protobuf::uint8* SerializeWithCachedSizesToArray(::google::protobuf::uint8* output) const;
  int GetCachedSize() const { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const;
  public:

  ::google::protobuf::Metadata GetMetadata() const;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  // optional bytes Msg = 1;
  inline bool has_msg() const;
  inline void clear_msg();
  static const int kMsgFieldNumber = 1;
  inline const ::std::string& msg() const;
  inline void set_msg(const ::std::string& value);
  inline void set_msg(const char* value);
  inline void set_msg(const void* value, size_t size);
  inline ::std::string* mutable_msg();
  inline ::std::string* release_msg();
  inline void set_allocated_msg(::std::string* msg);

  // @@protoc_insertion_point(class_scope:GateRpcBroadcastMsgNotify)
 private:
  inline void set_has_msg();
  inline void clear_has_msg();

  ::google::protobuf::UnknownFieldSet _unknown_fields_;

  ::std::string* msg_;

  mutable int _cached_size_;
  ::google::protobuf::uint32 _has_bits_[(1 + 31) / 32];

  friend void  protobuf_AddDesc_GateSvrRpc_2eproto();
  friend void protobuf_AssignDesc_GateSvrRpc_2eproto();
  friend void protobuf_ShutdownFile_GateSvrRpc_2eproto();

  void InitAsDefaultInstance();
  static GateRpcBroadcastMsgNotify* default_instance_;
};
// -------------------------------------------------------------------

class GateRpcCloseNodeNotify : public ::google::protobuf::Message {
 public:
  GateRpcCloseNodeNotify();
  virtual ~GateRpcCloseNodeNotify();

  GateRpcCloseNodeNotify(const GateRpcCloseNodeNotify& from);

  inline GateRpcCloseNodeNotify& operator=(const GateRpcCloseNodeNotify& from) {
    CopyFrom(from);
    return *this;
  }

  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _unknown_fields_;
  }

  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return &_unknown_fields_;
  }

  static const ::google::protobuf::Descriptor* descriptor();
  static const GateRpcCloseNodeNotify& default_instance();

  void Swap(GateRpcCloseNodeNotify* other);

  // implements Message ----------------------------------------------

  GateRpcCloseNodeNotify* New() const;
  void CopyFrom(const ::google::protobuf::Message& from);
  void MergeFrom(const ::google::protobuf::Message& from);
  void CopyFrom(const GateRpcCloseNodeNotify& from);
  void MergeFrom(const GateRpcCloseNodeNotify& from);
  void Clear();
  bool IsInitialized() const;

  int ByteSize() const;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input);
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const;
  ::google::protobuf::uint8* SerializeWithCachedSizesToArray(::google::protobuf::uint8* output) const;
  int GetCachedSize() const { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const;
  public:

  ::google::protobuf::Metadata GetMetadata() const;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  // repeated sint64 UidArr = 1;
  inline int uidarr_size() const;
  inline void clear_uidarr();
  static const int kUidArrFieldNumber = 1;
  inline ::google::protobuf::int64 uidarr(int index) const;
  inline void set_uidarr(int index, ::google::protobuf::int64 value);
  inline void add_uidarr(::google::protobuf::int64 value);
  inline const ::google::protobuf::RepeatedField< ::google::protobuf::int64 >&
      uidarr() const;
  inline ::google::protobuf::RepeatedField< ::google::protobuf::int64 >*
      mutable_uidarr();

  // @@protoc_insertion_point(class_scope:GateRpcCloseNodeNotify)
 private:

  ::google::protobuf::UnknownFieldSet _unknown_fields_;

  ::google::protobuf::RepeatedField< ::google::protobuf::int64 > uidarr_;

  mutable int _cached_size_;
  ::google::protobuf::uint32 _has_bits_[(1 + 31) / 32];

  friend void  protobuf_AddDesc_GateSvrRpc_2eproto();
  friend void protobuf_AssignDesc_GateSvrRpc_2eproto();
  friend void protobuf_ShutdownFile_GateSvrRpc_2eproto();

  void InitAsDefaultInstance();
  static GateRpcCloseNodeNotify* default_instance_;
};
// -------------------------------------------------------------------

class GateRpcRegisterModuleNotify : public ::google::protobuf::Message {
 public:
  GateRpcRegisterModuleNotify();
  virtual ~GateRpcRegisterModuleNotify();

  GateRpcRegisterModuleNotify(const GateRpcRegisterModuleNotify& from);

  inline GateRpcRegisterModuleNotify& operator=(const GateRpcRegisterModuleNotify& from) {
    CopyFrom(from);
    return *this;
  }

  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _unknown_fields_;
  }

  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return &_unknown_fields_;
  }

  static const ::google::protobuf::Descriptor* descriptor();
  static const GateRpcRegisterModuleNotify& default_instance();

  void Swap(GateRpcRegisterModuleNotify* other);

  // implements Message ----------------------------------------------

  GateRpcRegisterModuleNotify* New() const;
  void CopyFrom(const ::google::protobuf::Message& from);
  void MergeFrom(const ::google::protobuf::Message& from);
  void CopyFrom(const GateRpcRegisterModuleNotify& from);
  void MergeFrom(const GateRpcRegisterModuleNotify& from);
  void Clear();
  bool IsInitialized() const;

  int ByteSize() const;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input);
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const;
  ::google::protobuf::uint8* SerializeWithCachedSizesToArray(::google::protobuf::uint8* output) const;
  int GetCachedSize() const { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const;
  public:

  ::google::protobuf::Metadata GetMetadata() const;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  // repeated sint32 ModuleIdArr = 1;
  inline int moduleidarr_size() const;
  inline void clear_moduleidarr();
  static const int kModuleIdArrFieldNumber = 1;
  inline ::google::protobuf::int32 moduleidarr(int index) const;
  inline void set_moduleidarr(int index, ::google::protobuf::int32 value);
  inline void add_moduleidarr(::google::protobuf::int32 value);
  inline const ::google::protobuf::RepeatedField< ::google::protobuf::int32 >&
      moduleidarr() const;
  inline ::google::protobuf::RepeatedField< ::google::protobuf::int32 >*
      mutable_moduleidarr();

  // @@protoc_insertion_point(class_scope:GateRpcRegisterModuleNotify)
 private:

  ::google::protobuf::UnknownFieldSet _unknown_fields_;

  ::google::protobuf::RepeatedField< ::google::protobuf::int32 > moduleidarr_;

  mutable int _cached_size_;
  ::google::protobuf::uint32 _has_bits_[(1 + 31) / 32];

  friend void  protobuf_AddDesc_GateSvrRpc_2eproto();
  friend void protobuf_AssignDesc_GateSvrRpc_2eproto();
  friend void protobuf_ShutdownFile_GateSvrRpc_2eproto();

  void InitAsDefaultInstance();
  static GateRpcRegisterModuleNotify* default_instance_;
};
// -------------------------------------------------------------------

class GateRpcKickNotify : public ::google::protobuf::Message {
 public:
  GateRpcKickNotify();
  virtual ~GateRpcKickNotify();

  GateRpcKickNotify(const GateRpcKickNotify& from);

  inline GateRpcKickNotify& operator=(const GateRpcKickNotify& from) {
    CopyFrom(from);
    return *this;
  }

  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _unknown_fields_;
  }

  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return &_unknown_fields_;
  }

  static const ::google::protobuf::Descriptor* descriptor();
  static const GateRpcKickNotify& default_instance();

  void Swap(GateRpcKickNotify* other);

  // implements Message ----------------------------------------------

  GateRpcKickNotify* New() const;
  void CopyFrom(const ::google::protobuf::Message& from);
  void MergeFrom(const ::google::protobuf::Message& from);
  void CopyFrom(const GateRpcKickNotify& from);
  void MergeFrom(const GateRpcKickNotify& from);
  void Clear();
  bool IsInitialized() const;

  int ByteSize() const;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input);
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const;
  ::google::protobuf::uint8* SerializeWithCachedSizesToArray(::google::protobuf::uint8* output) const;
  int GetCachedSize() const { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const;
  public:

  ::google::protobuf::Metadata GetMetadata() const;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  // optional sint64 Uid = 1 [default = -1];
  inline bool has_uid() const;
  inline void clear_uid();
  static const int kUidFieldNumber = 1;
  inline ::google::protobuf::int64 uid() const;
  inline void set_uid(::google::protobuf::int64 value);

  // @@protoc_insertion_point(class_scope:GateRpcKickNotify)
 private:
  inline void set_has_uid();
  inline void clear_has_uid();

  ::google::protobuf::UnknownFieldSet _unknown_fields_;

  ::google::protobuf::int64 uid_;

  mutable int _cached_size_;
  ::google::protobuf::uint32 _has_bits_[(1 + 31) / 32];

  friend void  protobuf_AddDesc_GateSvrRpc_2eproto();
  friend void protobuf_AssignDesc_GateSvrRpc_2eproto();
  friend void protobuf_ShutdownFile_GateSvrRpc_2eproto();

  void InitAsDefaultInstance();
  static GateRpcKickNotify* default_instance_;
};
// -------------------------------------------------------------------

class GateRpcOnlineNotify : public ::google::protobuf::Message {
 public:
  GateRpcOnlineNotify();
  virtual ~GateRpcOnlineNotify();

  GateRpcOnlineNotify(const GateRpcOnlineNotify& from);

  inline GateRpcOnlineNotify& operator=(const GateRpcOnlineNotify& from) {
    CopyFrom(from);
    return *this;
  }

  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _unknown_fields_;
  }

  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return &_unknown_fields_;
  }

  static const ::google::protobuf::Descriptor* descriptor();
  static const GateRpcOnlineNotify& default_instance();

  void Swap(GateRpcOnlineNotify* other);

  // implements Message ----------------------------------------------

  GateRpcOnlineNotify* New() const;
  void CopyFrom(const ::google::protobuf::Message& from);
  void MergeFrom(const ::google::protobuf::Message& from);
  void CopyFrom(const GateRpcOnlineNotify& from);
  void MergeFrom(const GateRpcOnlineNotify& from);
  void Clear();
  bool IsInitialized() const;

  int ByteSize() const;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input);
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const;
  ::google::protobuf::uint8* SerializeWithCachedSizesToArray(::google::protobuf::uint8* output) const;
  int GetCachedSize() const { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const;
  public:

  ::google::protobuf::Metadata GetMetadata() const;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  // optional sint32 NodeId = 1 [default = -1];
  inline bool has_nodeid() const;
  inline void clear_nodeid();
  static const int kNodeIdFieldNumber = 1;
  inline ::google::protobuf::int32 nodeid() const;
  inline void set_nodeid(::google::protobuf::int32 value);

  // optional sint64 Uid = 2 [default = -1];
  inline bool has_uid() const;
  inline void clear_uid();
  static const int kUidFieldNumber = 2;
  inline ::google::protobuf::int64 uid() const;
  inline void set_uid(::google::protobuf::int64 value);

  // optional string Name = 3;
  inline bool has_name() const;
  inline void clear_name();
  static const int kNameFieldNumber = 3;
  inline const ::std::string& name() const;
  inline void set_name(const ::std::string& value);
  inline void set_name(const char* value);
  inline void set_name(const char* value, size_t size);
  inline ::std::string* mutable_name();
  inline ::std::string* release_name();
  inline void set_allocated_name(::std::string* name);

  // @@protoc_insertion_point(class_scope:GateRpcOnlineNotify)
 private:
  inline void set_has_nodeid();
  inline void clear_has_nodeid();
  inline void set_has_uid();
  inline void clear_has_uid();
  inline void set_has_name();
  inline void clear_has_name();

  ::google::protobuf::UnknownFieldSet _unknown_fields_;

  ::google::protobuf::int64 uid_;
  ::std::string* name_;
  ::google::protobuf::int32 nodeid_;

  mutable int _cached_size_;
  ::google::protobuf::uint32 _has_bits_[(3 + 31) / 32];

  friend void  protobuf_AddDesc_GateSvrRpc_2eproto();
  friend void protobuf_AssignDesc_GateSvrRpc_2eproto();
  friend void protobuf_ShutdownFile_GateSvrRpc_2eproto();

  void InitAsDefaultInstance();
  static GateRpcOnlineNotify* default_instance_;
};
// ===================================================================


// ===================================================================

// GateRpcSendMsgNotify

// repeated sint64 UidArr = 1;
inline int GateRpcSendMsgNotify::uidarr_size() const {
  return uidarr_.size();
}
inline void GateRpcSendMsgNotify::clear_uidarr() {
  uidarr_.Clear();
}
inline ::google::protobuf::int64 GateRpcSendMsgNotify::uidarr(int index) const {
  return uidarr_.Get(index);
}
inline void GateRpcSendMsgNotify::set_uidarr(int index, ::google::protobuf::int64 value) {
  uidarr_.Set(index, value);
}
inline void GateRpcSendMsgNotify::add_uidarr(::google::protobuf::int64 value) {
  uidarr_.Add(value);
}
inline const ::google::protobuf::RepeatedField< ::google::protobuf::int64 >&
GateRpcSendMsgNotify::uidarr() const {
  return uidarr_;
}
inline ::google::protobuf::RepeatedField< ::google::protobuf::int64 >*
GateRpcSendMsgNotify::mutable_uidarr() {
  return &uidarr_;
}

// optional bytes Msg = 2;
inline bool GateRpcSendMsgNotify::has_msg() const {
  return (_has_bits_[0] & 0x00000002u) != 0;
}
inline void GateRpcSendMsgNotify::set_has_msg() {
  _has_bits_[0] |= 0x00000002u;
}
inline void GateRpcSendMsgNotify::clear_has_msg() {
  _has_bits_[0] &= ~0x00000002u;
}
inline void GateRpcSendMsgNotify::clear_msg() {
  if (msg_ != &::google::protobuf::internal::kEmptyString) {
    msg_->clear();
  }
  clear_has_msg();
}
inline const ::std::string& GateRpcSendMsgNotify::msg() const {
  return *msg_;
}
inline void GateRpcSendMsgNotify::set_msg(const ::std::string& value) {
  set_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    msg_ = new ::std::string;
  }
  msg_->assign(value);
}
inline void GateRpcSendMsgNotify::set_msg(const char* value) {
  set_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    msg_ = new ::std::string;
  }
  msg_->assign(value);
}
inline void GateRpcSendMsgNotify::set_msg(const void* value, size_t size) {
  set_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    msg_ = new ::std::string;
  }
  msg_->assign(reinterpret_cast<const char*>(value), size);
}
inline ::std::string* GateRpcSendMsgNotify::mutable_msg() {
  set_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    msg_ = new ::std::string;
  }
  return msg_;
}
inline ::std::string* GateRpcSendMsgNotify::release_msg() {
  clear_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    return NULL;
  } else {
    ::std::string* temp = msg_;
    msg_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
    return temp;
  }
}
inline void GateRpcSendMsgNotify::set_allocated_msg(::std::string* msg) {
  if (msg_ != &::google::protobuf::internal::kEmptyString) {
    delete msg_;
  }
  if (msg) {
    set_has_msg();
    msg_ = msg;
  } else {
    clear_has_msg();
    msg_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  }
}

// -------------------------------------------------------------------

// GateRpcBroadcastMsgNotify

// optional bytes Msg = 1;
inline bool GateRpcBroadcastMsgNotify::has_msg() const {
  return (_has_bits_[0] & 0x00000001u) != 0;
}
inline void GateRpcBroadcastMsgNotify::set_has_msg() {
  _has_bits_[0] |= 0x00000001u;
}
inline void GateRpcBroadcastMsgNotify::clear_has_msg() {
  _has_bits_[0] &= ~0x00000001u;
}
inline void GateRpcBroadcastMsgNotify::clear_msg() {
  if (msg_ != &::google::protobuf::internal::kEmptyString) {
    msg_->clear();
  }
  clear_has_msg();
}
inline const ::std::string& GateRpcBroadcastMsgNotify::msg() const {
  return *msg_;
}
inline void GateRpcBroadcastMsgNotify::set_msg(const ::std::string& value) {
  set_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    msg_ = new ::std::string;
  }
  msg_->assign(value);
}
inline void GateRpcBroadcastMsgNotify::set_msg(const char* value) {
  set_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    msg_ = new ::std::string;
  }
  msg_->assign(value);
}
inline void GateRpcBroadcastMsgNotify::set_msg(const void* value, size_t size) {
  set_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    msg_ = new ::std::string;
  }
  msg_->assign(reinterpret_cast<const char*>(value), size);
}
inline ::std::string* GateRpcBroadcastMsgNotify::mutable_msg() {
  set_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    msg_ = new ::std::string;
  }
  return msg_;
}
inline ::std::string* GateRpcBroadcastMsgNotify::release_msg() {
  clear_has_msg();
  if (msg_ == &::google::protobuf::internal::kEmptyString) {
    return NULL;
  } else {
    ::std::string* temp = msg_;
    msg_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
    return temp;
  }
}
inline void GateRpcBroadcastMsgNotify::set_allocated_msg(::std::string* msg) {
  if (msg_ != &::google::protobuf::internal::kEmptyString) {
    delete msg_;
  }
  if (msg) {
    set_has_msg();
    msg_ = msg;
  } else {
    clear_has_msg();
    msg_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  }
}

// -------------------------------------------------------------------

// GateRpcCloseNodeNotify

// repeated sint64 UidArr = 1;
inline int GateRpcCloseNodeNotify::uidarr_size() const {
  return uidarr_.size();
}
inline void GateRpcCloseNodeNotify::clear_uidarr() {
  uidarr_.Clear();
}
inline ::google::protobuf::int64 GateRpcCloseNodeNotify::uidarr(int index) const {
  return uidarr_.Get(index);
}
inline void GateRpcCloseNodeNotify::set_uidarr(int index, ::google::protobuf::int64 value) {
  uidarr_.Set(index, value);
}
inline void GateRpcCloseNodeNotify::add_uidarr(::google::protobuf::int64 value) {
  uidarr_.Add(value);
}
inline const ::google::protobuf::RepeatedField< ::google::protobuf::int64 >&
GateRpcCloseNodeNotify::uidarr() const {
  return uidarr_;
}
inline ::google::protobuf::RepeatedField< ::google::protobuf::int64 >*
GateRpcCloseNodeNotify::mutable_uidarr() {
  return &uidarr_;
}

// -------------------------------------------------------------------

// GateRpcRegisterModuleNotify

// repeated sint32 ModuleIdArr = 1;
inline int GateRpcRegisterModuleNotify::moduleidarr_size() const {
  return moduleidarr_.size();
}
inline void GateRpcRegisterModuleNotify::clear_moduleidarr() {
  moduleidarr_.Clear();
}
inline ::google::protobuf::int32 GateRpcRegisterModuleNotify::moduleidarr(int index) const {
  return moduleidarr_.Get(index);
}
inline void GateRpcRegisterModuleNotify::set_moduleidarr(int index, ::google::protobuf::int32 value) {
  moduleidarr_.Set(index, value);
}
inline void GateRpcRegisterModuleNotify::add_moduleidarr(::google::protobuf::int32 value) {
  moduleidarr_.Add(value);
}
inline const ::google::protobuf::RepeatedField< ::google::protobuf::int32 >&
GateRpcRegisterModuleNotify::moduleidarr() const {
  return moduleidarr_;
}
inline ::google::protobuf::RepeatedField< ::google::protobuf::int32 >*
GateRpcRegisterModuleNotify::mutable_moduleidarr() {
  return &moduleidarr_;
}

// -------------------------------------------------------------------

// GateRpcKickNotify

// optional sint64 Uid = 1 [default = -1];
inline bool GateRpcKickNotify::has_uid() const {
  return (_has_bits_[0] & 0x00000001u) != 0;
}
inline void GateRpcKickNotify::set_has_uid() {
  _has_bits_[0] |= 0x00000001u;
}
inline void GateRpcKickNotify::clear_has_uid() {
  _has_bits_[0] &= ~0x00000001u;
}
inline void GateRpcKickNotify::clear_uid() {
  uid_ = GOOGLE_LONGLONG(-1);
  clear_has_uid();
}
inline ::google::protobuf::int64 GateRpcKickNotify::uid() const {
  return uid_;
}
inline void GateRpcKickNotify::set_uid(::google::protobuf::int64 value) {
  set_has_uid();
  uid_ = value;
}

// -------------------------------------------------------------------

// GateRpcOnlineNotify

// optional sint32 NodeId = 1 [default = -1];
inline bool GateRpcOnlineNotify::has_nodeid() const {
  return (_has_bits_[0] & 0x00000001u) != 0;
}
inline void GateRpcOnlineNotify::set_has_nodeid() {
  _has_bits_[0] |= 0x00000001u;
}
inline void GateRpcOnlineNotify::clear_has_nodeid() {
  _has_bits_[0] &= ~0x00000001u;
}
inline void GateRpcOnlineNotify::clear_nodeid() {
  nodeid_ = -1;
  clear_has_nodeid();
}
inline ::google::protobuf::int32 GateRpcOnlineNotify::nodeid() const {
  return nodeid_;
}
inline void GateRpcOnlineNotify::set_nodeid(::google::protobuf::int32 value) {
  set_has_nodeid();
  nodeid_ = value;
}

// optional sint64 Uid = 2 [default = -1];
inline bool GateRpcOnlineNotify::has_uid() const {
  return (_has_bits_[0] & 0x00000002u) != 0;
}
inline void GateRpcOnlineNotify::set_has_uid() {
  _has_bits_[0] |= 0x00000002u;
}
inline void GateRpcOnlineNotify::clear_has_uid() {
  _has_bits_[0] &= ~0x00000002u;
}
inline void GateRpcOnlineNotify::clear_uid() {
  uid_ = GOOGLE_LONGLONG(-1);
  clear_has_uid();
}
inline ::google::protobuf::int64 GateRpcOnlineNotify::uid() const {
  return uid_;
}
inline void GateRpcOnlineNotify::set_uid(::google::protobuf::int64 value) {
  set_has_uid();
  uid_ = value;
}

// optional string Name = 3;
inline bool GateRpcOnlineNotify::has_name() const {
  return (_has_bits_[0] & 0x00000004u) != 0;
}
inline void GateRpcOnlineNotify::set_has_name() {
  _has_bits_[0] |= 0x00000004u;
}
inline void GateRpcOnlineNotify::clear_has_name() {
  _has_bits_[0] &= ~0x00000004u;
}
inline void GateRpcOnlineNotify::clear_name() {
  if (name_ != &::google::protobuf::internal::kEmptyString) {
    name_->clear();
  }
  clear_has_name();
}
inline const ::std::string& GateRpcOnlineNotify::name() const {
  return *name_;
}
inline void GateRpcOnlineNotify::set_name(const ::std::string& value) {
  set_has_name();
  if (name_ == &::google::protobuf::internal::kEmptyString) {
    name_ = new ::std::string;
  }
  name_->assign(value);
}
inline void GateRpcOnlineNotify::set_name(const char* value) {
  set_has_name();
  if (name_ == &::google::protobuf::internal::kEmptyString) {
    name_ = new ::std::string;
  }
  name_->assign(value);
}
inline void GateRpcOnlineNotify::set_name(const char* value, size_t size) {
  set_has_name();
  if (name_ == &::google::protobuf::internal::kEmptyString) {
    name_ = new ::std::string;
  }
  name_->assign(reinterpret_cast<const char*>(value), size);
}
inline ::std::string* GateRpcOnlineNotify::mutable_name() {
  set_has_name();
  if (name_ == &::google::protobuf::internal::kEmptyString) {
    name_ = new ::std::string;
  }
  return name_;
}
inline ::std::string* GateRpcOnlineNotify::release_name() {
  clear_has_name();
  if (name_ == &::google::protobuf::internal::kEmptyString) {
    return NULL;
  } else {
    ::std::string* temp = name_;
    name_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
    return temp;
  }
}
inline void GateRpcOnlineNotify::set_allocated_name(::std::string* name) {
  if (name_ != &::google::protobuf::internal::kEmptyString) {
    delete name_;
  }
  if (name) {
    set_has_name();
    name_ = name;
  } else {
    clear_has_name();
    name_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  }
}


// @@protoc_insertion_point(namespace_scope)

#ifndef SWIG
namespace google {
namespace protobuf {


}  // namespace google
}  // namespace protobuf
#endif  // SWIG

// @@protoc_insertion_point(global_scope)

#endif  // PROTOBUF_GateSvrRpc_2eproto__INCLUDED