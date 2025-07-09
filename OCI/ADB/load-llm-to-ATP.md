## create auth token for the user
### create credentails in ATP
BEGIN 
  DBMS_CLOUD.CREATE_CREDENTIAL( 
    credential_name => 'MY_OCI_CRED', 
    username => 'oracleidentitycloudservice/nithin.sunke@oracle.com', 
    password => '68WBYGd3q9C9>6<>}f-j' 
  ); 
END; 

SELECT * FROM DBA_CREDENTIALS WHERE CREDENTIAL_NAME = 'MY_OCI_CRED';

### list the objects from object storage

select *
from   dbms_cloud.list_objects(
        credential_name => 'MY_OCI_CRED',
        location_uri    => 'https://objectstorage.me-jeddah-1.oraclecloud.com/n/frrudica1wgd/b/Jed_Bkt/o/');

### load ALL_MINILM into ATP
DECLARE
 model_file VARCHAR2(100) := 'all_MiniLM_L12_v2.onnx';
 model_name VARCHAR2(100) := 'ALL_MINILM';
 object_uri VARCHAR2(200) :=
  'https://objectstorage.me-jeddah-1.oraclecloud.com/n/frrudica1wgd/b/Jed_Bkt/o/' || model_file;
BEGIN
 -- Drop existing model if any
 BEGIN
  DBMS_VECTOR.DROP_ONNX_MODEL(model_name => model_name, force => TRUE);
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
 -- Load model from cloud
 DBMS_VECTOR.LOAD_ONNX_MODEL_CLOUD(
  model_name => model_name,
  credential => 'MY_OCI_CRED',
  uri    => object_uri,
  metadata => JSON(
   '{"function":"embedding","embeddingOutput":"embedding","input":{"input":["DATA"]}}'
  )
 );
END;
/

### list the loaded models

SELECT model_name, mining_function
FROM user_mining_models
WHERE model_name = 'ALL_MINILM';







