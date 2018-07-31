
import coremltools
model_spec = coremltools.utils.load_spec('/Users/liuxinzhong/video/video/video/coreMLModels/HED_so.mlmodel')

coremltools.utils.rename_feature(model_spec, 'upscore-dsn1', 'upscore_dsn1')
coremltools.utils.rename_feature(model_spec, 'upscore-dsn2', 'upscore_dsn2')
coremltools.utils.rename_feature(model_spec, 'upscore-dsn3', 'upscore_dsn3')
coremltools.utils.rename_feature(model_spec, 'upscore-dsn4', 'upscore_dsn4')
coremltools.utils.rename_feature(model_spec, 'upscore-dsn5', 'upscore_dsn55')
coremltools.utils.save_spec(model_spec,'/Users/liuxinzhong/video/video/video/coreMLModels/HEDso_1.mlmodel')
print(1111)
