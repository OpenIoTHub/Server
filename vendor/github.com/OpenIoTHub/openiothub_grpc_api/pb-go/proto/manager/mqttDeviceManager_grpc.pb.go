// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.2.0
// - protoc             v4.24.3
// source: mqttDeviceManager.proto

package pb

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

// MqttDeviceManagerClient is the client API for MqttDeviceManager service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type MqttDeviceManagerClient interface {
	// 对MQTT类型设备的操作
	AddMqttDevice(ctx context.Context, in *MqttDeviceInfo, opts ...grpc.CallOption) (*OperationResponse, error)
	DelMqttDevice(ctx context.Context, in *MqttDeviceInfo, opts ...grpc.CallOption) (*OperationResponse, error)
	GetAllMqttDevice(ctx context.Context, in *Empty, opts ...grpc.CallOption) (*MqttDeviceInfoList, error)
	// 设备生成mqtt登录信息
	GenerateMqttUsernamePassword(ctx context.Context, in *MqttDeviceInfo, opts ...grpc.CallOption) (*MqttInfo, error)
	// 获取所有的mqtt Broker
	GetAllMqttBrokers(ctx context.Context, in *Empty, opts ...grpc.CallOption) (*MqttBrokerList, error)
}

type mqttDeviceManagerClient struct {
	cc grpc.ClientConnInterface
}

func NewMqttDeviceManagerClient(cc grpc.ClientConnInterface) MqttDeviceManagerClient {
	return &mqttDeviceManagerClient{cc}
}

func (c *mqttDeviceManagerClient) AddMqttDevice(ctx context.Context, in *MqttDeviceInfo, opts ...grpc.CallOption) (*OperationResponse, error) {
	out := new(OperationResponse)
	err := c.cc.Invoke(ctx, "/pb.MqttDeviceManager/AddMqttDevice", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *mqttDeviceManagerClient) DelMqttDevice(ctx context.Context, in *MqttDeviceInfo, opts ...grpc.CallOption) (*OperationResponse, error) {
	out := new(OperationResponse)
	err := c.cc.Invoke(ctx, "/pb.MqttDeviceManager/DelMqttDevice", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *mqttDeviceManagerClient) GetAllMqttDevice(ctx context.Context, in *Empty, opts ...grpc.CallOption) (*MqttDeviceInfoList, error) {
	out := new(MqttDeviceInfoList)
	err := c.cc.Invoke(ctx, "/pb.MqttDeviceManager/GetAllMqttDevice", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *mqttDeviceManagerClient) GenerateMqttUsernamePassword(ctx context.Context, in *MqttDeviceInfo, opts ...grpc.CallOption) (*MqttInfo, error) {
	out := new(MqttInfo)
	err := c.cc.Invoke(ctx, "/pb.MqttDeviceManager/GenerateMqttUsernamePassword", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *mqttDeviceManagerClient) GetAllMqttBrokers(ctx context.Context, in *Empty, opts ...grpc.CallOption) (*MqttBrokerList, error) {
	out := new(MqttBrokerList)
	err := c.cc.Invoke(ctx, "/pb.MqttDeviceManager/GetAllMqttBrokers", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// MqttDeviceManagerServer is the server API for MqttDeviceManager service.
// All implementations must embed UnimplementedMqttDeviceManagerServer
// for forward compatibility
type MqttDeviceManagerServer interface {
	// 对MQTT类型设备的操作
	AddMqttDevice(context.Context, *MqttDeviceInfo) (*OperationResponse, error)
	DelMqttDevice(context.Context, *MqttDeviceInfo) (*OperationResponse, error)
	GetAllMqttDevice(context.Context, *Empty) (*MqttDeviceInfoList, error)
	// 设备生成mqtt登录信息
	GenerateMqttUsernamePassword(context.Context, *MqttDeviceInfo) (*MqttInfo, error)
	// 获取所有的mqtt Broker
	GetAllMqttBrokers(context.Context, *Empty) (*MqttBrokerList, error)
	mustEmbedUnimplementedMqttDeviceManagerServer()
}

// UnimplementedMqttDeviceManagerServer must be embedded to have forward compatible implementations.
type UnimplementedMqttDeviceManagerServer struct {
}

func (UnimplementedMqttDeviceManagerServer) AddMqttDevice(context.Context, *MqttDeviceInfo) (*OperationResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method AddMqttDevice not implemented")
}
func (UnimplementedMqttDeviceManagerServer) DelMqttDevice(context.Context, *MqttDeviceInfo) (*OperationResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method DelMqttDevice not implemented")
}
func (UnimplementedMqttDeviceManagerServer) GetAllMqttDevice(context.Context, *Empty) (*MqttDeviceInfoList, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetAllMqttDevice not implemented")
}
func (UnimplementedMqttDeviceManagerServer) GenerateMqttUsernamePassword(context.Context, *MqttDeviceInfo) (*MqttInfo, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GenerateMqttUsernamePassword not implemented")
}
func (UnimplementedMqttDeviceManagerServer) GetAllMqttBrokers(context.Context, *Empty) (*MqttBrokerList, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetAllMqttBrokers not implemented")
}
func (UnimplementedMqttDeviceManagerServer) mustEmbedUnimplementedMqttDeviceManagerServer() {}

// UnsafeMqttDeviceManagerServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to MqttDeviceManagerServer will
// result in compilation errors.
type UnsafeMqttDeviceManagerServer interface {
	mustEmbedUnimplementedMqttDeviceManagerServer()
}

func RegisterMqttDeviceManagerServer(s grpc.ServiceRegistrar, srv MqttDeviceManagerServer) {
	s.RegisterService(&MqttDeviceManager_ServiceDesc, srv)
}

func _MqttDeviceManager_AddMqttDevice_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(MqttDeviceInfo)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(MqttDeviceManagerServer).AddMqttDevice(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/pb.MqttDeviceManager/AddMqttDevice",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(MqttDeviceManagerServer).AddMqttDevice(ctx, req.(*MqttDeviceInfo))
	}
	return interceptor(ctx, in, info, handler)
}

func _MqttDeviceManager_DelMqttDevice_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(MqttDeviceInfo)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(MqttDeviceManagerServer).DelMqttDevice(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/pb.MqttDeviceManager/DelMqttDevice",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(MqttDeviceManagerServer).DelMqttDevice(ctx, req.(*MqttDeviceInfo))
	}
	return interceptor(ctx, in, info, handler)
}

func _MqttDeviceManager_GetAllMqttDevice_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(Empty)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(MqttDeviceManagerServer).GetAllMqttDevice(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/pb.MqttDeviceManager/GetAllMqttDevice",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(MqttDeviceManagerServer).GetAllMqttDevice(ctx, req.(*Empty))
	}
	return interceptor(ctx, in, info, handler)
}

func _MqttDeviceManager_GenerateMqttUsernamePassword_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(MqttDeviceInfo)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(MqttDeviceManagerServer).GenerateMqttUsernamePassword(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/pb.MqttDeviceManager/GenerateMqttUsernamePassword",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(MqttDeviceManagerServer).GenerateMqttUsernamePassword(ctx, req.(*MqttDeviceInfo))
	}
	return interceptor(ctx, in, info, handler)
}

func _MqttDeviceManager_GetAllMqttBrokers_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(Empty)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(MqttDeviceManagerServer).GetAllMqttBrokers(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/pb.MqttDeviceManager/GetAllMqttBrokers",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(MqttDeviceManagerServer).GetAllMqttBrokers(ctx, req.(*Empty))
	}
	return interceptor(ctx, in, info, handler)
}

// MqttDeviceManager_ServiceDesc is the grpc.ServiceDesc for MqttDeviceManager service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var MqttDeviceManager_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "pb.MqttDeviceManager",
	HandlerType: (*MqttDeviceManagerServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "AddMqttDevice",
			Handler:    _MqttDeviceManager_AddMqttDevice_Handler,
		},
		{
			MethodName: "DelMqttDevice",
			Handler:    _MqttDeviceManager_DelMqttDevice_Handler,
		},
		{
			MethodName: "GetAllMqttDevice",
			Handler:    _MqttDeviceManager_GetAllMqttDevice_Handler,
		},
		{
			MethodName: "GenerateMqttUsernamePassword",
			Handler:    _MqttDeviceManager_GenerateMqttUsernamePassword_Handler,
		},
		{
			MethodName: "GetAllMqttBrokers",
			Handler:    _MqttDeviceManager_GetAllMqttBrokers_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "mqttDeviceManager.proto",
}