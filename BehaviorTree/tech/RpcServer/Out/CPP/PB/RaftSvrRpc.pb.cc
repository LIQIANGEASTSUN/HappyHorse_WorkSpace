// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: RaftSvrRpc.proto

#define INTERNAL_SUPPRESS_PROTOBUF_FIELD_DEPRECATION
#include "RaftSvrRpc.pb.h"

#include <algorithm>

#include <google/protobuf/stubs/common.h>
#include <google/protobuf/stubs/once.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/wire_format_lite_inl.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/generated_message_reflection.h>
#include <google/protobuf/reflection_ops.h>
#include <google/protobuf/wire_format.h>
// @@protoc_insertion_point(includes)

namespace {

const ::google::protobuf::Descriptor* RaftRpcTickNotify_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  RaftRpcTickNotify_reflection_ = NULL;
const ::google::protobuf::Descriptor* RaftRpcVoteNotify_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  RaftRpcVoteNotify_reflection_ = NULL;
const ::google::protobuf::Descriptor* RaftRpcSyncLogNotify_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  RaftRpcSyncLogNotify_reflection_ = NULL;

}  // namespace


void protobuf_AssignDesc_RaftSvrRpc_2eproto() {
  protobuf_AddDesc_RaftSvrRpc_2eproto();
  const ::google::protobuf::FileDescriptor* file =
    ::google::protobuf::DescriptorPool::generated_pool()->FindFileByName(
      "RaftSvrRpc.proto");
  GOOGLE_CHECK(file != NULL);
  RaftRpcTickNotify_descriptor_ = file->message_type(0);
  static const int RaftRpcTickNotify_offsets_[2] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcTickNotify, type_),
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcTickNotify, addr_),
  };
  RaftRpcTickNotify_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      RaftRpcTickNotify_descriptor_,
      RaftRpcTickNotify::default_instance_,
      RaftRpcTickNotify_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcTickNotify, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcTickNotify, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(RaftRpcTickNotify));
  RaftRpcVoteNotify_descriptor_ = file->message_type(1);
  static const int RaftRpcVoteNotify_offsets_[1] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcVoteNotify, type_),
  };
  RaftRpcVoteNotify_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      RaftRpcVoteNotify_descriptor_,
      RaftRpcVoteNotify::default_instance_,
      RaftRpcVoteNotify_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcVoteNotify, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcVoteNotify, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(RaftRpcVoteNotify));
  RaftRpcSyncLogNotify_descriptor_ = file->message_type(2);
  static const int RaftRpcSyncLogNotify_offsets_[2] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcSyncLogNotify, type_),
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcSyncLogNotify, data_),
  };
  RaftRpcSyncLogNotify_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      RaftRpcSyncLogNotify_descriptor_,
      RaftRpcSyncLogNotify::default_instance_,
      RaftRpcSyncLogNotify_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcSyncLogNotify, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(RaftRpcSyncLogNotify, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(RaftRpcSyncLogNotify));
}

namespace {

GOOGLE_PROTOBUF_DECLARE_ONCE(protobuf_AssignDescriptors_once_);
inline void protobuf_AssignDescriptorsOnce() {
  ::google::protobuf::GoogleOnceInit(&protobuf_AssignDescriptors_once_,
                 &protobuf_AssignDesc_RaftSvrRpc_2eproto);
}

void protobuf_RegisterTypes(const ::std::string&) {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    RaftRpcTickNotify_descriptor_, &RaftRpcTickNotify::default_instance());
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    RaftRpcVoteNotify_descriptor_, &RaftRpcVoteNotify::default_instance());
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    RaftRpcSyncLogNotify_descriptor_, &RaftRpcSyncLogNotify::default_instance());
}

}  // namespace

void protobuf_ShutdownFile_RaftSvrRpc_2eproto() {
  delete RaftRpcTickNotify::default_instance_;
  delete RaftRpcTickNotify_reflection_;
  delete RaftRpcVoteNotify::default_instance_;
  delete RaftRpcVoteNotify_reflection_;
  delete RaftRpcSyncLogNotify::default_instance_;
  delete RaftRpcSyncLogNotify_reflection_;
}

void protobuf_AddDesc_RaftSvrRpc_2eproto() {
  static bool already_here = false;
  if (already_here) return;
  already_here = true;
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  ::google::protobuf::DescriptorPool::InternalAddGeneratedFile(
    "\n\020RaftSvrRpc.proto\"3\n\021RaftRpcTickNotify\022"
    "\020\n\004Type\030\002 \001(\021:\002-1\022\014\n\004Addr\030\003 \001(\014\"%\n\021RaftR"
    "pcVoteNotify\022\020\n\004Type\030\001 \001(\021:\002-1\"6\n\024RaftRp"
    "cSyncLogNotify\022\020\n\004Type\030\001 \001(\021:\002-1\022\014\n\004Data"
    "\030\002 \001(\014", 166);
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedFile(
    "RaftSvrRpc.proto", &protobuf_RegisterTypes);
  RaftRpcTickNotify::default_instance_ = new RaftRpcTickNotify();
  RaftRpcVoteNotify::default_instance_ = new RaftRpcVoteNotify();
  RaftRpcSyncLogNotify::default_instance_ = new RaftRpcSyncLogNotify();
  RaftRpcTickNotify::default_instance_->InitAsDefaultInstance();
  RaftRpcVoteNotify::default_instance_->InitAsDefaultInstance();
  RaftRpcSyncLogNotify::default_instance_->InitAsDefaultInstance();
  ::google::protobuf::internal::OnShutdown(&protobuf_ShutdownFile_RaftSvrRpc_2eproto);
}

// Force AddDescriptors() to be called at static initialization time.
struct StaticDescriptorInitializer_RaftSvrRpc_2eproto {
  StaticDescriptorInitializer_RaftSvrRpc_2eproto() {
    protobuf_AddDesc_RaftSvrRpc_2eproto();
  }
} static_descriptor_initializer_RaftSvrRpc_2eproto_;

// ===================================================================

#ifndef _MSC_VER
const int RaftRpcTickNotify::kTypeFieldNumber;
const int RaftRpcTickNotify::kAddrFieldNumber;
#endif  // !_MSC_VER

RaftRpcTickNotify::RaftRpcTickNotify()
  : ::google::protobuf::Message() {
  SharedCtor();
}

void RaftRpcTickNotify::InitAsDefaultInstance() {
}

RaftRpcTickNotify::RaftRpcTickNotify(const RaftRpcTickNotify& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
}

void RaftRpcTickNotify::SharedCtor() {
  _cached_size_ = 0;
  type_ = -1;
  addr_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

RaftRpcTickNotify::~RaftRpcTickNotify() {
  SharedDtor();
}

void RaftRpcTickNotify::SharedDtor() {
  if (addr_ != &::google::protobuf::internal::kEmptyString) {
    delete addr_;
  }
  if (this != default_instance_) {
  }
}

void RaftRpcTickNotify::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* RaftRpcTickNotify::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return RaftRpcTickNotify_descriptor_;
}

const RaftRpcTickNotify& RaftRpcTickNotify::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_RaftSvrRpc_2eproto();
  return *default_instance_;
}

RaftRpcTickNotify* RaftRpcTickNotify::default_instance_ = NULL;

RaftRpcTickNotify* RaftRpcTickNotify::New() const {
  return new RaftRpcTickNotify;
}

void RaftRpcTickNotify::Clear() {
  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    type_ = -1;
    if (has_addr()) {
      if (addr_ != &::google::protobuf::internal::kEmptyString) {
        addr_->clear();
      }
    }
  }
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool RaftRpcTickNotify::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) return false
  ::google::protobuf::uint32 tag;
  while ((tag = input->ReadTag()) != 0) {
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // optional sint32 Type = 2 [default = -1];
      case 2: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
          DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                   ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SINT32>(
                 input, &type_)));
          set_has_type();
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectTag(26)) goto parse_Addr;
        break;
      }

      // optional bytes Addr = 3;
      case 3: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
         parse_Addr:
          DO_(::google::protobuf::internal::WireFormatLite::ReadBytes(
                input, this->mutable_addr()));
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectAtEnd()) return true;
        break;
      }

      default: {
      handle_uninterpreted:
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          return true;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
  return true;
#undef DO_
}

void RaftRpcTickNotify::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // optional sint32 Type = 2 [default = -1];
  if (has_type()) {
    ::google::protobuf::internal::WireFormatLite::WriteSInt32(2, this->type(), output);
  }

  // optional bytes Addr = 3;
  if (has_addr()) {
    ::google::protobuf::internal::WireFormatLite::WriteBytes(
      3, this->addr(), output);
  }

  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
}

::google::protobuf::uint8* RaftRpcTickNotify::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // optional sint32 Type = 2 [default = -1];
  if (has_type()) {
    target = ::google::protobuf::internal::WireFormatLite::WriteSInt32ToArray(2, this->type(), target);
  }

  // optional bytes Addr = 3;
  if (has_addr()) {
    target =
      ::google::protobuf::internal::WireFormatLite::WriteBytesToArray(
        3, this->addr(), target);
  }

  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  return target;
}

int RaftRpcTickNotify::ByteSize() const {
  int total_size = 0;

  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // optional sint32 Type = 2 [default = -1];
    if (has_type()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::SInt32Size(
          this->type());
    }

    // optional bytes Addr = 3;
    if (has_addr()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::BytesSize(
          this->addr());
    }

  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void RaftRpcTickNotify::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const RaftRpcTickNotify* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const RaftRpcTickNotify*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void RaftRpcTickNotify::MergeFrom(const RaftRpcTickNotify& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_type()) {
      set_type(from.type());
    }
    if (from.has_addr()) {
      set_addr(from.addr());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void RaftRpcTickNotify::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void RaftRpcTickNotify::CopyFrom(const RaftRpcTickNotify& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool RaftRpcTickNotify::IsInitialized() const {

  return true;
}

void RaftRpcTickNotify::Swap(RaftRpcTickNotify* other) {
  if (other != this) {
    std::swap(type_, other->type_);
    std::swap(addr_, other->addr_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata RaftRpcTickNotify::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = RaftRpcTickNotify_descriptor_;
  metadata.reflection = RaftRpcTickNotify_reflection_;
  return metadata;
}


// ===================================================================

#ifndef _MSC_VER
const int RaftRpcVoteNotify::kTypeFieldNumber;
#endif  // !_MSC_VER

RaftRpcVoteNotify::RaftRpcVoteNotify()
  : ::google::protobuf::Message() {
  SharedCtor();
}

void RaftRpcVoteNotify::InitAsDefaultInstance() {
}

RaftRpcVoteNotify::RaftRpcVoteNotify(const RaftRpcVoteNotify& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
}

void RaftRpcVoteNotify::SharedCtor() {
  _cached_size_ = 0;
  type_ = -1;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

RaftRpcVoteNotify::~RaftRpcVoteNotify() {
  SharedDtor();
}

void RaftRpcVoteNotify::SharedDtor() {
  if (this != default_instance_) {
  }
}

void RaftRpcVoteNotify::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* RaftRpcVoteNotify::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return RaftRpcVoteNotify_descriptor_;
}

const RaftRpcVoteNotify& RaftRpcVoteNotify::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_RaftSvrRpc_2eproto();
  return *default_instance_;
}

RaftRpcVoteNotify* RaftRpcVoteNotify::default_instance_ = NULL;

RaftRpcVoteNotify* RaftRpcVoteNotify::New() const {
  return new RaftRpcVoteNotify;
}

void RaftRpcVoteNotify::Clear() {
  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    type_ = -1;
  }
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool RaftRpcVoteNotify::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) return false
  ::google::protobuf::uint32 tag;
  while ((tag = input->ReadTag()) != 0) {
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // optional sint32 Type = 1 [default = -1];
      case 1: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
          DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                   ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SINT32>(
                 input, &type_)));
          set_has_type();
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectAtEnd()) return true;
        break;
      }

      default: {
      handle_uninterpreted:
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          return true;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
  return true;
#undef DO_
}

void RaftRpcVoteNotify::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // optional sint32 Type = 1 [default = -1];
  if (has_type()) {
    ::google::protobuf::internal::WireFormatLite::WriteSInt32(1, this->type(), output);
  }

  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
}

::google::protobuf::uint8* RaftRpcVoteNotify::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // optional sint32 Type = 1 [default = -1];
  if (has_type()) {
    target = ::google::protobuf::internal::WireFormatLite::WriteSInt32ToArray(1, this->type(), target);
  }

  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  return target;
}

int RaftRpcVoteNotify::ByteSize() const {
  int total_size = 0;

  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // optional sint32 Type = 1 [default = -1];
    if (has_type()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::SInt32Size(
          this->type());
    }

  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void RaftRpcVoteNotify::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const RaftRpcVoteNotify* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const RaftRpcVoteNotify*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void RaftRpcVoteNotify::MergeFrom(const RaftRpcVoteNotify& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_type()) {
      set_type(from.type());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void RaftRpcVoteNotify::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void RaftRpcVoteNotify::CopyFrom(const RaftRpcVoteNotify& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool RaftRpcVoteNotify::IsInitialized() const {

  return true;
}

void RaftRpcVoteNotify::Swap(RaftRpcVoteNotify* other) {
  if (other != this) {
    std::swap(type_, other->type_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata RaftRpcVoteNotify::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = RaftRpcVoteNotify_descriptor_;
  metadata.reflection = RaftRpcVoteNotify_reflection_;
  return metadata;
}


// ===================================================================

#ifndef _MSC_VER
const int RaftRpcSyncLogNotify::kTypeFieldNumber;
const int RaftRpcSyncLogNotify::kDataFieldNumber;
#endif  // !_MSC_VER

RaftRpcSyncLogNotify::RaftRpcSyncLogNotify()
  : ::google::protobuf::Message() {
  SharedCtor();
}

void RaftRpcSyncLogNotify::InitAsDefaultInstance() {
}

RaftRpcSyncLogNotify::RaftRpcSyncLogNotify(const RaftRpcSyncLogNotify& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
}

void RaftRpcSyncLogNotify::SharedCtor() {
  _cached_size_ = 0;
  type_ = -1;
  data_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

RaftRpcSyncLogNotify::~RaftRpcSyncLogNotify() {
  SharedDtor();
}

void RaftRpcSyncLogNotify::SharedDtor() {
  if (data_ != &::google::protobuf::internal::kEmptyString) {
    delete data_;
  }
  if (this != default_instance_) {
  }
}

void RaftRpcSyncLogNotify::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* RaftRpcSyncLogNotify::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return RaftRpcSyncLogNotify_descriptor_;
}

const RaftRpcSyncLogNotify& RaftRpcSyncLogNotify::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_RaftSvrRpc_2eproto();
  return *default_instance_;
}

RaftRpcSyncLogNotify* RaftRpcSyncLogNotify::default_instance_ = NULL;

RaftRpcSyncLogNotify* RaftRpcSyncLogNotify::New() const {
  return new RaftRpcSyncLogNotify;
}

void RaftRpcSyncLogNotify::Clear() {
  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    type_ = -1;
    if (has_data()) {
      if (data_ != &::google::protobuf::internal::kEmptyString) {
        data_->clear();
      }
    }
  }
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool RaftRpcSyncLogNotify::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) return false
  ::google::protobuf::uint32 tag;
  while ((tag = input->ReadTag()) != 0) {
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // optional sint32 Type = 1 [default = -1];
      case 1: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
          DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                   ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SINT32>(
                 input, &type_)));
          set_has_type();
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectTag(18)) goto parse_Data;
        break;
      }

      // optional bytes Data = 2;
      case 2: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
         parse_Data:
          DO_(::google::protobuf::internal::WireFormatLite::ReadBytes(
                input, this->mutable_data()));
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectAtEnd()) return true;
        break;
      }

      default: {
      handle_uninterpreted:
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          return true;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
  return true;
#undef DO_
}

void RaftRpcSyncLogNotify::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // optional sint32 Type = 1 [default = -1];
  if (has_type()) {
    ::google::protobuf::internal::WireFormatLite::WriteSInt32(1, this->type(), output);
  }

  // optional bytes Data = 2;
  if (has_data()) {
    ::google::protobuf::internal::WireFormatLite::WriteBytes(
      2, this->data(), output);
  }

  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
}

::google::protobuf::uint8* RaftRpcSyncLogNotify::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // optional sint32 Type = 1 [default = -1];
  if (has_type()) {
    target = ::google::protobuf::internal::WireFormatLite::WriteSInt32ToArray(1, this->type(), target);
  }

  // optional bytes Data = 2;
  if (has_data()) {
    target =
      ::google::protobuf::internal::WireFormatLite::WriteBytesToArray(
        2, this->data(), target);
  }

  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  return target;
}

int RaftRpcSyncLogNotify::ByteSize() const {
  int total_size = 0;

  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // optional sint32 Type = 1 [default = -1];
    if (has_type()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::SInt32Size(
          this->type());
    }

    // optional bytes Data = 2;
    if (has_data()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::BytesSize(
          this->data());
    }

  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void RaftRpcSyncLogNotify::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const RaftRpcSyncLogNotify* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const RaftRpcSyncLogNotify*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void RaftRpcSyncLogNotify::MergeFrom(const RaftRpcSyncLogNotify& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_type()) {
      set_type(from.type());
    }
    if (from.has_data()) {
      set_data(from.data());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void RaftRpcSyncLogNotify::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void RaftRpcSyncLogNotify::CopyFrom(const RaftRpcSyncLogNotify& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool RaftRpcSyncLogNotify::IsInitialized() const {

  return true;
}

void RaftRpcSyncLogNotify::Swap(RaftRpcSyncLogNotify* other) {
  if (other != this) {
    std::swap(type_, other->type_);
    std::swap(data_, other->data_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata RaftRpcSyncLogNotify::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = RaftRpcSyncLogNotify_descriptor_;
  metadata.reflection = RaftRpcSyncLogNotify_reflection_;
  return metadata;
}


// @@protoc_insertion_point(namespace_scope)

// @@protoc_insertion_point(global_scope)