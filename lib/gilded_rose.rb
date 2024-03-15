class GildedRose
  def initialize(item)
    @item = item
  end

  def tick
    @item.update_quality
  end
end

class Item
  attr_reader :name, :days_remaining, :quality

  def initialize(name:, days_remaining:, quality:)
    @name = name
    @days_remaining = days_remaining
    @quality = quality
  end

  def update_quality
    decrease_sell_in
    quality_updater.update_quality
  end

  private

  def decrease_sell_in
    @days_remaining -= 1 unless sulfuras?
  end

  def quality_updater
    QualityUpdaterFactory.for_item(self)
  end

  def sulfuras?
    @name == "Sulfuras, Hand of Ragnaros"
  end
end

class QualityUpdaterFactory
  def self.for_item(item)
    case item.name
    when "Aged Brie"
      AgedBrieQualityUpdater.new(item)
    when "Backstage passes to a TAFKAL80ETC concert"
      BackstagePassQualityUpdater.new(item)
    when "Sulfuras, Hand of Ragnaros"
      SulfurasQualityUpdater.new(item)
    else
      NormalItemQualityUpdater.new(item)
    end
  end
end

class QualityUpdater
  def initialize(item)
    @item = item
  end

  def update_quality
    raise NotImplementedError, "Subclasses must implement update_quality method"
  end
end

class AgedBrieQualityUpdater < QualityUpdater
  def update_quality
    increment_quality if @item.quality < 50
  end

  private

  def increment_quality
    @item.quality += 1
  end
end

class BackstagePassQualityUpdater < QualityUpdater
  def update_quality
    case
    when @item.days_remaining > 10 then increment_quality_by(1)
    when @item.days_remaining.between?(6, 10) then increment_quality_by(2)
    when @item.days_remaining.between?(1, 5) then increment_quality_by(3)
    else @item.quality = 0
    end
  end

  private

  def increment_quality_by(value)
    @item.quality += value
    @item.quality = 50 if @item.quality > 50
  end
end

class SulfurasQualityUpdater < QualityUpdater
  def update_quality
    # Sulfuras quality never changes
  end
end

class NormalItemQualityUpdater < QualityUpdater
  def update_quality
    decrease_quality
  end

  private

  def decrease_quality
    @item.quality -= 1 if @item.quality > 0
    @item.quality -= 1 if @item.days_remaining <= 0 && @item.quality > 0
  end
end
