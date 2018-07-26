# 脚本目的是将model中中划线命名的feature改成别的，防止奔溃
import coremltools
model_spec = coremltools.utils.load_spec('/Users/liuxinzhong/video/video/video/coreMLModels/HEDso3.mlmodel')

coremltools.utils.rename_feature(model_spec, 'upscore-dsn3', 'upscore_dsn3')
coremltools.utils.save_spec(model_spec,'/Users/liuxinzhong/video/video/video/coreMLModels/HEDso3_1.mlmodel')
print(1111)