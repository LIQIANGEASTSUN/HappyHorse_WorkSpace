/********************************************************************************************
* Copyright (C), 2011-2025, AGAN Tech. Co., Ltd.
* FileName:     Module$Template$.cpp
* Author:       ��ҵ��
* Description:  $ModCName$�࣬������������
*               ��ģ�������Ϣ����
*               ���ʼ�������ص�����
*               ��ʱ����ػص�����
*               ���û����������߻ص�����
*               �������RPC����
*               ��ͻ���RPC����
* Version:      1.0
* History:
* <author>  <time>   <version >   <desc>
* 
********************************************************************************************/

#include "Module$Template$.h"

#ifdef WIN32
#ifdef _DEBUG
#pragma comment(lib,"../MOM/logic.lib")
#endif
#endif


IMPLEMENT_INSTANCE(Module$Template$);

//$ModCName$ʵ���๹�캯��
Module$Template$::Module$Template$()
{
$CliOperationImpl$
	RpcImpInfoT Imp;
	Imp.Name = "$Template$";
	Imp.Code = $TemplateCode$;
$ImplementRegister$
	RpcCenter::Instance().RegisterRpcImplement(Imp);
}

//$ModCName$ʵ������������
Module$Template$::~Module$Template$()
{

}


//��ȡģ��ID
UINT8 Module$Template$::GetModuleId()
{
	return MODULE_ID_$TEMPLATE$;
}

//��ȡģ������
TStr Module$Template$::GetModuleName()
{
	return "$Template$";
}

//��ʼ��
bool Module$Template$::Initialize()
{

	return true;
}

//�����˳�
void Module$Template$::Finalize()
{

}


//���뼶Tick�ص�
void Module$Template$::OnTick( INT64 currentMiliSecond )
{

}

//�뼶Tick�ص�
void Module$Template$::OnSecondTick( time_t currentSecond )
{

}

//���Ӹı�ص�
void Module$Template$::OnMinuteChange( time_t currentSecond)
{

}

//Сʱ�ı�ص�
void Module$Template$::OnHourChange( time_t currentSecond )
{

}

//��ı�ص�
void Module$Template$::OnDayChange( time_t currentSecond )
{

}

//�����û��ص�
void Module$Template$::OnUserCreate( INT64 uid, const TStr& userName )
{

}

//�û����߻ص�
void Module$Template$::OnUserOnline( INT64 uid, time_t lastLogoutTime )
{

}

//�û����߻ص�
void Module$Template$::OnUserOffline( INT64 uid )
{

}

//���ñ����
void Module$Template$::OnConfigReload(const TStr& tableName)
{

}

//�з�����Ϣ
void Module$Template$::OnPublish(const TStr& publishString)
{
	
}
