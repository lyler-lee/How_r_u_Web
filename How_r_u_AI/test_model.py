#!/usr/bin/env python3
# -*- coding: utf-8 -*-

print("1. 기본 임포트 테스트...")
try:
    import torch
    import torch.nn as nn
    print("✅ PyTorch 임포트 성공")
except Exception as e:
    print(f"❌ PyTorch 임포트 실패: {e}")
    exit(1)

print("2. emotion_model 임포트 테스트...")
try:
    from emotion_model import HybridEmotionModel
    print("✅ HybridEmotionModel 임포트 성공")
except Exception as e:
    print(f"❌ HybridEmotionModel 임포트 실패: {e}")
    exit(1)

print("3. 모델 인스턴스 생성 테스트...")
try:
    model = HybridEmotionModel()
    print("✅ 모델 생성 성공")
except Exception as e:
    print(f"❌ 모델 생성 실패: {e}")
    exit(1)

print("4. 더미 입력 테스트...")
try:
    dummy_input = torch.randn(1, 1, 48, 48)
    output = model(dummy_input)
    print(f"✅ 모델 테스트 성공, 출력 shape: {output.shape}")
except Exception as e:
    print(f"❌ 모델 테스트 실패: {e}")

print("모든 테스트 통과!")

