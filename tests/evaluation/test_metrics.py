from evaluation.src.metrics import evaluate

def test_accuracy_range():
    acc = evaluate([1,0,1],[1,0,0])
    assert 0 <= acc <= 1
