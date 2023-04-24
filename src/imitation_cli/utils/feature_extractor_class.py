import dataclasses

from hydra.core.config_store import ConfigStore
from omegaconf import MISSING


@dataclasses.dataclass
class Config:
    _target_: str = MISSING


@dataclasses.dataclass
class FlattenExtractorConfig(Config):
    _target_: str = "imitation_cli.utils.feature_extractor_class.FlattenExtractorConfig.make"

    @staticmethod
    def make() -> type:
        import stable_baselines3

        return stable_baselines3.common.torch_layers.FlattenExtractor


@dataclasses.dataclass
class NatureCNNConfig(Config):
    _target_: str = "imitation_cli.utils.feature_extractor_class.NatureCNNConfig.make"

    @staticmethod
    def make() -> type:
        import stable_baselines3

        return stable_baselines3.common.torch_layers.NatureCNN


def register_configs(group: str):
    cs = ConfigStore.instance()
    cs.store(group=group, name="flatten", node=FlattenExtractorConfig)
    cs.store(group=group, name="nature_cnn", node=NatureCNNConfig)